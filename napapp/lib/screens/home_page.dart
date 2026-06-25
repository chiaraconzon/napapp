import 'dart:async';
import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';
import 'package:napapp/widgets/time_picker.dart';
import 'package:napapp/services/notification_service.dart';
import 'app_strings.dart';

// =============================================================================
// MODELLO DATI SONNO
// =============================================================================
class SleepDay {
  final DateTime date;
  final double tst;
  final List<double> naps;
  const SleepDay({required this.date, required this.tst, this.naps = const []});
}

// =============================================================================
// ENUM ZONA
// =============================================================================
enum NapZone { green, yellow, orange, red }

// =============================================================================
// RISULTATO ALGORITMO
// =============================================================================
class NapResult {
  final NapZone zone;
  final int napEffectiveMin;
  final int totalDisplayMin;
  final TimeOfDay? suggestedStart;
  final TimeOfDay? suggestedEnd;
  final String scope;
  final String scopeEmoji;
  final bool hasInertiaWarning;

  const NapResult({
    required this.zone,
    required this.napEffectiveMin,
    required this.totalDisplayMin,
    this.suggestedStart,
    this.suggestedEnd,
    required this.scope,
    required this.scopeEmoji,
    this.hasInertiaWarning = false,
  });
}

// =============================================================================
// LIMITI ZONE
// =============================================================================
class ZoneLimits {
  final int greenStart;
  final int greenEnd;
  final int yellowEnd;
  final int orangeEnd;
  const ZoneLimits({
    required this.greenStart,
    required this.greenEnd,
    required this.yellowEnd,
    required this.orangeEnd,
  });
}

// =============================================================================
// ALGORITMO NAP
// =============================================================================
class NapAlgorithm {
  final double sleepTarget;
  final int latencyMin;
  final List<SleepDay> sleepHistory;
  final List<MyEvent> todayEvents;
  final TimeOfDay? wakeUpToday;
  final TimeOfDay? averageSchoolWakeUp;
  final DateTime today;

  NapAlgorithm({
    required this.sleepTarget,
    required this.latencyMin,
    required this.sleepHistory,
    required this.todayEvents,
    required this.wakeUpToday,
    required this.averageSchoolWakeUp,
    required this.today,
  });

  // ---- helpers ----
  static int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  static int hm(int h, int m) => h * 60 + m;
  static TimeOfDay fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
  static String fmtMin(int m) {
    final h = (m ~/ 60) % 24;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

// ---- SDS ----
// Valore fisso temporaneo in attesa dell'integrazione con il wearable.
// 0.0 = nessun debito (propone pisolino da 15 min)
// 1.5 = debito moderato (propone pisolino da 90 min)
static const double _sdsDebug = 0.8;

double computeSDS() => _sdsDebug;

  // ---- sveglia effettiva ----
  TimeOfDay? get _effectiveWakeUp => wakeUpToday ?? averageSchoolWakeUp;

  // ---- tipo giorno ----
  bool get _isSaturday => today.weekday == DateTime.saturday;
  bool get _isSunday => today.weekday == DateTime.sunday;

  // ---- inizio zona verde (fine pranzo + 40 min, altrimenti 14:00) ----
  int _zoneStartMin() {
    final pranzi = todayEvents.where((e) => e.category == 'Pranzo').toList();
    if (pranzi.isNotEmpty) {
      pranzi.sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));
      return toMin(pranzi.first.endTime) + 40;
    }
    return hm(14, 0);
  }

  // ---- limiti zone ----
  ZoneLimits computeZoneLimits() {
    final zoneStart = _zoneStartMin();

    if (_isSaturday) {
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd: hm(15, 30),
        yellowEnd: hm(16, 30),
        orangeEnd: hm(18, 0),
      );
    }

    if (_effectiveWakeUp == null) {
      return ZoneLimits(
        greenStart: hm(14, 0),
        greenEnd: hm(15, 0),
        yellowEnd: hm(16, 0),
        orangeEnd: hm(17, 30),
      );
    }

    // domenica: usa media scolastica lun-gio
    final wakeUp = _isSunday
        ? (averageSchoolWakeUp ?? _effectiveWakeUp!)
        : _effectiveWakeUp!;
    final bedtimeMin = (toMin(wakeUp) - 8 * 60 + 24 * 60) % (24 * 60);
    // yellowEnd non può superare le 17:30 (se lo raggiunge la zona arancione scompare)
    final yellowEnd = (bedtimeMin - 7 * 60).clamp(zoneStart, hm(17, 30));
    // greenEnd non può superare yellowEnd
    final greenEnd  = (bedtimeMin - 8 * 60).clamp(zoneStart, yellowEnd);

    return ZoneLimits(
      greenStart: zoneStart,
      greenEnd:   greenEnd,
      yellowEnd:  yellowEnd,
      orangeEnd:  hm(17, 30),
    );
  }

  NapZone _zoneOfOffset(int offsetMin, ZoneLimits lim) {
    if (offsetMin <= lim.greenEnd) return NapZone.green;
    if (offsetMin <= lim.yellowEnd) return NapZone.yellow;
    if (offsetMin <= lim.orangeEnd) return NapZone.orange;
    return NapZone.red;
  }

  // ---- durata target ----
  // Valori ammessi: 90,85,80,75,70,65,60,30,25,20,15,10
  static const List<int> napSteps = [
    90,
    85,
    80,
    75,
    70,
    65,
    60,
    30,
    25,
    20,
    15,
    10,
  ];

  int _idealDuration(double sds) {
    if (sds > 1.0) return 90;
    final hasStudy = todayEvents.any(
      (e) => e.category == 'Studio' || e.category == 'Lezione',
    );
    if (hasStudy) return 30;
    return 15;
  }

  // ---- inerzie ----
  int _inerziaCogn(int n) {
    if (n <= 15) return 0;
    if (n <= 25) return 10;
    if (n <= 30) return 15;
    if (n <= 75) return 30;
    return 35;
  }

  int _inerziaMotor(int n) {
    if (n <= 15) return 30;
    if (n <= 25) return 40;
    if (n <= 30) return 50;
    if (n <= 75) return 80;
    return 100;
  }

  // ---- label scopo ----
  String _scopeLabel(int n) {
    if (n >= 60) return 'Energie';
    if (n >= 20) return 'Memoria';
    return 'Riflessi';
  }

  String _scopeEmoji(int n) {
    if (n >= 60) return '🔋';
    if (n >= 20) return '🧠';
    return '⚡';
  }

  // ---- MOTORE PRINCIPALE ----
  NapResult compute() {
    final sds = computeSDS();
    final lim = computeZoneLimits();
    final now = TimeOfDay.now();
    final nowMin = toMin(now);

    if (nowMin >= lim.orangeEnd) return _noNap();

    final baseStart = nowMin > lim.greenStart ? nowMin : lim.greenStart;
    int stepIdx = napSteps.indexWhere((s) => s <= _idealDuration(sds));
    if (stepIdx == -1) stepIdx = napSteps.length - 1;

    // --- Calcola i buchi liberi tra [from, to] ---
    // Un buco è un intervallo senza eventi (Pranzo escluso).
    // Restituisce lista di (gapStart, gapEnd) già clippata a [from, to].
    List<(int, int)> buildGaps(int from, int to) {
      if (from >= to) return [];

      // Prendo tutti gli intervalli degli eventi (escluso Pranzo)
      final intervals =
          todayEvents
              .where((e) => e.category != 'Pranzo')
              .map((e) => (toMin(e.startTime), toMin(e.endTime)))
              .toList()
            ..sort((a, b) => a.$1.compareTo(b.$1));

      // Merge intervalli sovrapposti
      final merged = <(int, int)>[];
      for (final iv in intervals) {
        if (merged.isEmpty || iv.$1 >= merged.last.$2) {
          merged.add(iv);
        } else {
          final maxEnd = iv.$2 > merged.last.$2 ? iv.$2 : merged.last.$2;
          merged[merged.length - 1] = (merged.last.$1, maxEnd);
        }
      }

      // Costruisco i buchi
      final gaps = <(int, int)>[];
      int cursor = from;
      for (final iv in merged) {
        if (iv.$1 > cursor) {
          // c'è spazio libero prima di questo evento
          final gStart = cursor;
          final gEnd = iv.$1 < to ? iv.$1 : to;
          if (gStart < gEnd) gaps.add((gStart, gEnd));
        }
        if (iv.$2 > cursor) cursor = iv.$2;
      }
      if (cursor < to) gaps.add((cursor, to));

      return gaps;
    }

    // --- Ciclo principale: scala napMin fino a trovare uno slot ---
    while (stepIdx < napSteps.length) {
      final napMin = napSteps[stepIdx];
      final cogn = _inerziaCogn(napMin);
      final motor = _inerziaMotor(napMin);
      final needed = latencyMin + napMin;

      // Buchi disponibili da ora fino a fine zona gialla
      // (il pisolino deve TERMINARE entro yellowEnd)
      final gaps = buildGaps(baseStart, lim.yellowEnd);

      for (final gap in gaps) {
        final napStart = gap.$1;
        final napEnd = napStart + needed;

        // Il pisolino deve stare dentro il buco e finire entro yellowEnd
        if (napEnd > gap.$2) continue;
        if (napEnd > lim.yellowEnd) continue;

        // --- Verifica inerzie rispetto agli eventi SUCCESSIVI al pisolino ---
        final othersAfter =
            todayEvents
                .where(
                  (e) =>
                      e.category != 'Pranzo' &&
                      e.category != 'Allenamento' &&
                      toMin(e.startTime) >= napEnd,
                )
                .toList()
              ..sort(
                (a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)),
              );

        final allensAfter =
            todayEvents
                .where(
                  (e) =>
                      e.category == 'Allenamento' &&
                      toMin(e.startTime) >= napEnd,
                )
                .toList()
              ..sort(
                (a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)),
              );

        final cognGap = othersAfter.isEmpty
            ? 9999
            : toMin(othersAfter.first.startTime) - napEnd;
        final motorGap = allensAfter.isEmpty
            ? 9999
            : toMin(allensAfter.first.startTime) - napEnd;

        final cognOk = cognGap >= cogn;
        final motorOk = motorGap >= motor;

        if (cognOk && motorOk) {
          // Slot perfetto
          return NapResult(
            zone: _zoneOfOffset(napStart, lim),
            napEffectiveMin: napMin,
            totalDisplayMin: needed,
            suggestedStart: fromMin(napStart),
            suggestedEnd: fromMin(napEnd),
            scope: _scopeLabel(napMin),
            scopeEmoji: _scopeEmoji(napMin),
          );
        }

        // Se solo l'inerzia cognitiva è violata di ≤10 min e napMin ≥ 60:
        // si mette comunque con warning (inerzia motoria non si tocca mai)
        final cognViolation = cogn - cognGap;
        if (!cognOk && motorOk && napMin >= 60 && cognViolation <= 10) {
          return NapResult(
            zone: _zoneOfOffset(napStart, lim),
            napEffectiveMin: napMin,
            totalDisplayMin: needed,
            suggestedStart: fromMin(napStart),
            suggestedEnd: fromMin(napEnd),
            scope: _scopeLabel(napMin),
            scopeEmoji: _scopeEmoji(napMin),
            hasInertiaWarning: true,
          );
        }

        // Buco non valido: si passa al buco successivo automaticamente
      }

      // Nessun buco valido per questa durata: si scala di 5 min (step successivo)
      stepIdx++;
    }

    // --- Fallback zona arancione: 10 min + latenza (fisso) ---
    // Durata fissa → inerzia_cogn(10) = 0, inerzia_motor(10) = 30 min.
    // Regole:
    //   1. Il pisolino non si sovrappone ad altri eventi
    //   2. Ogni evento Allenamento successivo deve distare >= 30 min dalla fine
    //   3. Il pisolino deve finire entro orangeEnd (17:30)
    const orangeNap = 10;
    const orangeMotor = 30; // _inerziaMotor(10)
    final orangeNeeded = latencyMin + orangeNap;
    // Inizia la ricerca arancione 19 min prima della fine zona gialla
    // (latenza 10 + pisolino minimo 10 - 1 di margine = 19).
    // Così non si perde nessuna finestra utile tra la fine dello spazio
    // disponibile in giallo e l'inizio "ufficiale" della zona arancione.
    final orangeEarlyStart = lim.yellowEnd - 19;
    final orangeFrom = baseStart > orangeEarlyStart
        ? baseStart
        : orangeEarlyStart;

    // Buchi liberi dentro la zona arancione
    final orangeGaps = buildGaps(orangeFrom, lim.orangeEnd);

    for (final gap in orangeGaps) {
      final napStart = gap.$1;
      final napEnd = napStart + orangeNeeded;

      // Deve stare dentro il buco e finire entro orangeEnd
      if (napEnd > gap.$2) continue;
      if (napEnd > lim.orangeEnd) continue;

      // Inerzia motoria: allenamenti successivi devono distare >= 30 min
      final allensAfterOrange =
          todayEvents
              .where(
                (e) =>
                    e.category == 'Allenamento' && toMin(e.startTime) >= napEnd,
              )
              .toList()
            ..sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));

      final motorGapOrange = allensAfterOrange.isEmpty
          ? 9999
          : toMin(allensAfterOrange.first.startTime) - napEnd;

      if (motorGapOrange < orangeMotor) continue;

      // Slot valido
      return NapResult(
        zone: NapZone.orange,
        napEffectiveMin: orangeNap,
        totalDisplayMin: orangeNeeded,
        suggestedStart: fromMin(napStart),
        suggestedEnd: fromMin(napEnd),
        scope: _scopeLabel(orangeNap),
        scopeEmoji: _scopeEmoji(orangeNap),
      );
    }

    return _noNap();
  }

  NapResult _noNap() => const NapResult(
    zone: NapZone.red,
    napEffectiveMin: 0,
    totalDisplayMin: 0,
    scope: '',
    scopeEmoji: '',
  );
}

// =============================================================================
// ITEM LISTA (evento o pisolino)
// =============================================================================
class _ListItem {
  final MyEvent? event;
  final NapResult? napResult;
  _ListItem.event(this.event) : napResult = null;
  _ListItem.nap(this.napResult) : event = null;
  bool get isNap => napResult != null;
  int get startMin {
    if (isNap) {
      final s = napResult!.suggestedStart!;
      return s.hour * 60 + s.minute;
    }
    return event!.startTime.hour * 60 + event!.startTime.minute;
  }
}

// =============================================================================
// HOME PAGE
// =============================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<DateTime, List<MyEvent>> globalEvents = {};
  Duration selectedDuration = const Duration(minutes: 10);
  int _pageIndex = 0;
  int selectedAlarm = 1;
  bool _isEnglish = false;

  static const double _sleepTarget = 8.0;
  static const int _latencyMin = 10;
  static const TimeOfDay _defaultWakeUp = TimeOfDay(hour: 6, minute: 30);
  final List<SleepDay> _sleepHistory = [];

  Timer? _napTimer;
  NapResult? _napResult;
  ZoneLimits? _zoneLimits;
  double _sds = 0.0; // calcolato una volta sola in _updateNap

  @override
  void initState() {
    super.initState();
    _updateNap();
    _napTimer = Timer.periodic(
      const Duration(
        minutes: 1,
      ), // ho messo che refresha ogni minuto. In caso cambiare
      (_) {
        if (mounted) setState(_updateNap);
      },
    );
  }

  @override
  void dispose() {
    _napTimer?.cancel();
    super.dispose();
  }

  void _updateNap() {
    final now = DateTime.now();
    final key = DateTime(now.year, now.month, now.day);
    final algo = NapAlgorithm(
      sleepTarget: _sleepTarget,
      latencyMin: _latencyMin,
      sleepHistory: _sleepHistory,
      todayEvents: globalEvents[key] ?? [],
      wakeUpToday: null,
      averageSchoolWakeUp: _defaultWakeUp,
      today: now,
    );
    _zoneLimits = algo.computeZoneLimits();
    _sds        = algo.computeSDS();
    _napResult  = algo.compute();
  }

  String _fmtTOD(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Pranzo':
        return Icons.restaurant;
      case 'Studio':
        return Icons.menu_book;
      case 'Allenamento':
        return Icons.fitness_center;
      case 'Lezione':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }

  Color _zoneColor(NapZone z) {
    switch (z) {
      case NapZone.green:
        return Colors.green;
      case NapZone.yellow:
        return Colors.amber;
      case NapZone.orange:
        return Colors.orange.shade800;
      case NapZone.red:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(_isEnglish);
    final name =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Utente';
    final pages = [
      _homeWidget(),
      CalendarPage(
        eventsMap: globalEvents,
        isEnglish: _isEnglish,
        onEventsUpdated: (m) => setState(() {
          globalEvents = m;
          _updateNap();
        }),
      ),
      StatsPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _pageIndex == 1
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Text(s.hello(name)))),
            ListTile(title: const Text('TEMA'), onTap: () {}),
            ListTile(
              title: const Text('LINGUA'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.selectLanguage),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Text('🇮🇹', style: TextStyle(fontSize: 24)),
                          title: const Text('Italiano'),
                          selected: !_isEnglish,
                          onTap: () {
                            setState(() => _isEnglish = false);
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                          title: const Text('English'),
                          selected: _isEnglish,
                          onTap: () {
                            setState(() => _isEnglish = true);
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('TUTORIAL'),
              onTap: () {
                Navigator.pop(context); // chiude il drawer prima di aprire il dialog
                _showTutorial(context);
              },
            ),
            ListTile(title: const Text('CREDITS'), onTap: () {}),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(s.logout),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
            ),
          ],
        ),
      ),
      body: pages[_pageIndex],
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  selectedAlarm = 0;
                });
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Dialog(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings(_isEnglish).chooseNapTime,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50),
                                TimerPicker(
                                  key: ValueKey(selectedDuration),
                                  duration: selectedDuration,
                                  onDurationChanged: (d) {
                                    setState(() => selectedDuration = d);
                                  },
                                ),
                                SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _chooseAlarmButton(
                                      context,
                                      1,
                                      10,
                                      selectedAlarm,
                                      (index) {
                                        setDialogState(() {
                                          selectedAlarm = index;
                                          selectedDuration = const Duration(
                                            minutes: 10,
                                          );
                                        });
                                      },
                                    ),

                                    _chooseAlarmButton(
                                      context,
                                      2,
                                      30,
                                      selectedAlarm,
                                      (index) {
                                        setDialogState(() {
                                          selectedAlarm = index;
                                          selectedDuration = const Duration(
                                            minutes: 30,
                                          );
                                        });
                                      },
                                    ),

                                    _chooseAlarmButton(
                                      context,
                                      3,
                                      90,
                                      selectedAlarm,
                                      (index) {
                                        setDialogState(() {
                                          selectedAlarm = index;
                                          selectedDuration = const Duration(
                                            minutes: 90,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 50),
                                ElevatedButton(
                                  onPressed: () async {
                                    final s = AppStrings(_isEnglish);
                                    final totalMinutes =
                                        selectedDuration.inMinutes;
                                    final hours = totalMinutes ~/ 60;
                                    final minutes = totalMinutes % 60;

                                    final message = s.alarmSet(hours, minutes);

                                    await NotificationService.showNapNotification(
                                      totalMinutes,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );

                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    AppStrings(_isEnglish).startAlarm,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.alarm),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: s.navHome),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: s.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: s.navStats,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // HOME WIDGET
  // -----------------------------------------------------------------------
  Widget _homeWidget() {
    final s = AppStrings(_isEnglish);
    final now = DateTime.now();
    final key = DateTime(now.year, now.month, now.day);
    final eventiOggi = List<MyEvent>.from(globalEvents[key] ?? [])
      ..sort((a, b) {
        final ma = a.startTime.hour * 60 + a.startTime.minute;
        final mb = b.startTime.hour * 60 + b.startTime.minute;
        return ma.compareTo(mb);
      });

    // Lista cronologica eventi + pisolino
    final items = <_ListItem>[];
    for (final ev in eventiOggi) items.add(_ListItem.event(ev));
    final r = _napResult;
    if (r != null &&
        r.zone != NapZone.red &&
        r.napEffectiveMin > 0 &&
        r.suggestedStart != null) {
      items.add(_ListItem.nap(r));
      items.sort((a, b) => a.startMin.compareTo(b.startMin));
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.todaySchedule,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                _sdsReward(_sds),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // stringa predizione
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _predictionString(),
          ),
          const SizedBox(height: 8),

          // debug zone
          if (_zoneLimits != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _debugZones(_zoneLimits!),
            ),
          const SizedBox(height: 8),

          // lista cronologica
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.noEvents,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => items[i].isNap
                        ? _napCard(items[i].napResult!)
                        : _eventCard(items[i].event!),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chooseAlarmButton(
    BuildContext context,
    int index,
    int minutes,
    int selectedIndex,
    Function(int) onSelected,
  ) {
    final isSelected = index == selectedIndex;
    String label =
        '${minutes ~/ 60}'.padLeft(2, '0') +
        ':' +
        '${minutes % 60}'.padLeft(2, '0');

    return SizedBox(
      child: OutlinedButton(
        onPressed: () {
          onSelected(index);
        },

        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),

          side: BorderSide(
            color: isSelected
                ? const Color.fromARGB(255, 241, 127, 5) // selezionato
                : Theme.of(context).colorScheme.primary,
            width: isSelected ? 3 : 2,
          ),

          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(25),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? const Color.fromARGB(255, 241, 127, 5)
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // CARD EVENTO
  // -----------------------------------------------------------------------
  Widget _eventCard(MyEvent ev) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: ev.color.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ev.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_catIcon(ev.category), color: ev.color, size: 28),
        ),
        title: Text(
          ev.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                '${_fmtTOD(ev.startTime)} - ${_fmtTOD(ev.endTime)}',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
        trailing: Text(
          ev.category,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // CARD PISOLINO
  // -----------------------------------------------------------------------
  Widget _napCard(NapResult r) {
    final s = AppStrings(_isEnglish);
    final color = _zoneColor(r.zone);
    final label = r.zone == NapZone.orange
        ? s.napEmergencyLabel
        : s.napLabel;
    final start = _fmtTOD(r.suggestedStart!);
    final end = _fmtTOD(r.suggestedEnd!);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withOpacity(0.7), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bedtime, color: color, size: 28),
          ),
          title: Text(
            '${r.scopeEmoji} $label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: color,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: color),
                    const SizedBox(width: 5),
                    Text(
                      '$start - $end',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  s.napDetails( r.totalDisplayMin,
                      s.translateScope(r.scope)),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (r.hasInertiaWarning) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.inertiaWarning,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // STRINGA PREDIZIONE
  // -----------------------------------------------------------------------
  Widget _predictionString() {
    final s = AppStrings(_isEnglish);
    final r = _napResult;

    if (r == null || r.zone == NapZone.red || r.napEffectiveMin == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.block, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 10),
            Text(
              s.redZoneMsg,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (r.zone == NapZone.orange) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade800),
        ),
        child: Text(
          s.orangeMsg,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.orange.shade800,
          ),
        ),
      );
    }

    final isGreen = r.zone == NapZone.green;
    final color = isGreen ? Colors.green : Colors.amber;
    final label = isGreen ? s.idealNap : s.emergencyNapPrediction;
    final start = _fmtTOD(r.suggestedStart!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isGreen ? Colors.green.shade700 : Colors.amber.shade600,
              ),
            ),
            TextSpan(
              text: '${r.totalDisplayMin} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '  •  '),
            TextSpan(text: '${r.scopeEmoji} ${s.translateScope(r.scope)}'),
            TextSpan(text: '  •  ${s.fromTime} '),
            TextSpan(
              text: start,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // DEBUG ZONE
  // -----------------------------------------------------------------------
  Widget _debugZones(ZoneLimits lim) {
    final s = AppStrings(_isEnglish);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔧 DEBUG ZONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          _dbRow(s.zoneGreen,
              '${NapAlgorithm.fmtMin(lim.greenStart)} → ${NapAlgorithm.fmtMin(lim.greenEnd)}',
              Colors.green),
          _dbRow(s.zoneYellow,
              '${NapAlgorithm.fmtMin(lim.greenEnd)} → ${NapAlgorithm.fmtMin(lim.yellowEnd)}',
              Colors.amber),
          _dbRow(s.zoneOrange,
              '${NapAlgorithm.fmtMin(lim.yellowEnd)} → ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
              Colors.orange.shade800),
          _dbRow(s.zoneRed,
              '${s.zoneBeyond} ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
              Colors.red),
        ],
      ),
    );
  }

  Widget _dbRow(String label, String val, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Text(val, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    ),
  );

  // -----------------------------------------------------------------------
  // SDS REWARD
  // -----------------------------------------------------------------------
  Widget _sdsReward(double sds) {
    final s = AppStrings(_isEnglish);
    late String emoji, label;
    late Color color;
    if (sds < 0.5) {
      emoji = '🔋'; label = s.sdsGreat;    color = Colors.green;
    } else if (sds < 1.0) {
      emoji = '🙂'; label = s.sdsLight;    color = Colors.lightGreen;
    } else if (sds < 2.0) {
      emoji = '🥱'; label = s.sdsModerate; color = Colors.orange.shade800;
    } else {
      emoji = '🚨'; label = s.sdsSevere;   color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TUTORIAL
  // ---------------------------------------------------------------------------

  static const List<Map<String, String>> _tutorialPages = [
    {
      'emoji': '👋',
      'title': 'Benvenuto in NapApp',
      'body':
          'NapApp ti aiuta a pianificare il pisolino perfetto in base ai tuoi impegni e al tuo debito di sonno. Scorri per scoprire come funziona.',
    },
    {
      'emoji': '🟢',
      'title': 'Le Zone Temporali',
      'body':
          'La giornata è divisa in quattro zone colorate: Verde (pisolino ideale), Gialla (emergenza), Arancione (finestra limitata) e Rossa (troppo tardi). Il colore del suggerimento dipende da quando riesci a dormire.',
    },
    {
      'emoji': '🔋',
      'title': 'Debito di Sonno (SDS)',
      'body':
          'L\'app calcola il tuo Saldo Debito Sonno pesando le ultime 7 notti con un coefficiente esponenziale (le notti recenti contano di più). Se il debito supera 1 ora, ti viene suggerito un pisolino di recupero da 90 min.',
    },
    {
      'emoji': '⏱️',
      'title': 'Durata del Pisolino',
      'body':
          'Esistono tre tipologie: 10–15 min per un boost immediato dei riflessi (⚡), 20–30 min per consolidare la memoria (🧠), 60–90 min per recuperare energie (🔋). L\'app sceglie la durata giusta per te automaticamente.',
    },
    {
      'emoji': '📅',
      'title': 'Aggiungere Impegni',
      'body':
          'Vai nella scheda Calendario e premi il tasto "+" per aggiungere un impegno. Puoi scegliere la categoria (Lezione, Pranzo, Studio, Allenamento, Altro), l\'orario e il colore. Puoi anche impostare la ripetizione settimanale o mensile.',
    },
    {
      'emoji': '🏋️',
      'title': 'Inerzia e Allenamento',
      'body':
          'Dopo un pisolino il corpo ha bisogno di tempo per essere pronto all\'attività fisica (inerzia motoria). L\'app assicura sempre una distanza adeguata tra la fine del pisolino e il tuo allenamento.',
    },
    {
      'emoji': '⏰',
      'title': 'Impostare la Sveglia',
      'body':
          'Dalla home puoi avviare una sveglia direttamente nell\'app: scegli la durata desiderata per il pisolino e premi "Avvia". Riceverai una notifica allo scadere del tempo.',
    },
    {
      'emoji': '📊',
      'title': 'Statistiche',
      'body':
          'Nella scheda Statistiche trovi il riepilogo del tuo sonno settimanale e l\'andamento del debito di sonno nel tempo. Più dati inserisci, più accurate diventano le previsioni dell\'app.',
    },
  ];

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _TutorialDialog(pages: _tutorialPages),
    );
  }
}

// =============================================================================
// TUTORIAL DIALOG
// =============================================================================

class _TutorialDialog extends StatefulWidget {
  final List<Map<String, String>> pages;
  const _TutorialDialog({required this.pages});

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  int _current = 0;

  void _prev() {
    if (_current > 0) setState(() => _current--);
  }

  void _next() {
    if (_current < widget.pages.length - 1) setState(() => _current++);
  }

  @override
  Widget build(BuildContext context) {
    final page    = widget.pages[_current];
    final total   = widget.pages.length;
    final isFirst = _current == 0;
    final isLast  = _current == total - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        children: [
          // ---- Contenuto principale ----
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji grande
                Text(page['emoji']!, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 16),

                // Titolo
                Text(
                  page['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Testo descrittivo
                Text(
                  page['body']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ---- Frecce + pallini indicatori ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Freccia sinistra (grigia alla prima pagina)
                    IconButton(
                      onPressed: isFirst ? null : _prev,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: isFirst ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),

                    // Pallini: quello attivo è più grande e scuro
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(total, (i) {
                        final isActive = i == _current;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width:  isActive ? 10 : 7,
                          height: isActive ? 10 : 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.black87
                                : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),

                    // Freccia destra (grigia all'ultima pagina)
                    IconButton(
                      onPressed: isLast ? null : _next,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: isLast ? Colors.grey.shade300 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---- Tasto X in alto a destra ----
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
