import 'dart:async';
import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';
import 'package:napapp/services/notification_service.dart';

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
  // Media pesata esponenzialmente su finestra mobile di 7 giorni (G-1…G-7).
  // Peso del giorno i (0-based, 0=G-1): λ^i con λ=0.65.
  // SDS = Σ(peso_i * deficit_i) / Σ(peso_i)
  // I giorni senza dati vengono saltati (peso non conteggiato).
  static const double _lambda = 0.65;

  double computeSDS() {
    if (sleepHistory.isEmpty) return 0.0;

    double deficit(SleepDay d) {
      final napsLong = d.naps
          .where((n) => n > 60)
          .fold(0.0, (a, b) => a + b / 60);
      return (sleepTarget - (d.tst + napsLong)).clamp(0.0, double.infinity);
    }

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < sleepHistory.length && i < 7; i++) {
      final weight = _pow(_lambda, i);
      weightedSum += weight * deficit(sleepHistory[i]);
      totalWeight += weight;
    }

    return totalWeight == 0.0 ? 0.0 : weightedSum / totalWeight;
  }

  /// Calcola base^exp senza dart:math (evita import aggiuntivi)
  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) result *= base;
    return result;
  }

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

    return ZoneLimits(
      greenStart: zoneStart,
      greenEnd: bedtimeMin - 8 * 60,
      yellowEnd: bedtimeMin - 7 * 60,
      orangeEnd: hm(17, 30),
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

  // ---- check inerzie: 'ok' | 'warning' | 'no' ----
  String _checkInertia(int napMin, int offset) {
    final cogn = _inerziaCogn(napMin);
    final motor = _inerziaMotor(napMin);
    final hasAllenamento = todayEvents.any((e) => e.category == 'Allenamento');

    // eventi non-allenamento dopo l'offset
    final others = todayEvents
        .where(
          (e) =>
              e.category != 'Allenamento' &&
              e.category != 'Pranzo' &&
              toMin(e.startTime) > offset,
        )
        .toList();
    if (others.isNotEmpty) {
      others.sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));
      final gap = toMin(others.first.startTime) - offset;
      if (gap < cogn) {
        final overlap = cogn - gap;
        if (napMin >= 60 && overlap <= 10) return 'warning';
        return 'no';
      }
    }

    // eventi allenamento dopo l'offset
    final allens = todayEvents
        .where(
          (e) => e.category == 'Allenamento' && toMin(e.startTime) > offset,
        )
        .toList();
    if (allens.isNotEmpty) {
      allens.sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));
      final gap = toMin(allens.first.startTime) - offset;
      if (gap < motor) return 'no';
    }

    return 'ok';
  }

  // ---- sovrapposizione con eventi (escluso Pranzo) ----
  bool _overlaps(int startMin, int endMin) {
    for (final ev in todayEvents) {
      if (ev.category == 'Pranzo') continue;
      final s = toMin(ev.startTime);
      final e = toMin(ev.endTime);
      if (startMin < e && endMin > s) return true;
    }
    return false;
  }

  // Sposta startMin oltre eventi sovrapposti
  int _skipOverlaps(int startMin) {
    bool moved = true;
    while (moved) {
      moved = false;
      for (final ev in todayEvents) {
        if (ev.category == 'Pranzo') continue;
        final s = toMin(ev.startTime);
        final e = toMin(ev.endTime);
        if (startMin >= s && startMin < e) {
          startMin = e;
          moved = true;
          break;
        }
      }
    }
    return startMin;
  }

  // Fine del prossimo evento che inizia >= afterMin
  int? _nextEventEnd(int afterMin) {
    final list = todayEvents
        .where((e) => e.category != 'Pranzo' && toMin(e.startTime) >= afterMin)
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));
    return toMin(list.first.endTime);
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
    final nowMin = toMin(TimeOfDay.now());

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
  int _pageIndex = 0;

  static const double _sleepTarget = 8.0;
  static const int _latencyMin = 10;
  static const TimeOfDay _defaultWakeUp = TimeOfDay(hour: 6, minute: 30);
  final List<SleepDay> _sleepHistory = [];

  Timer? _napTimer;
  NapResult? _napResult;
  ZoneLimits? _zoneLimits;

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
    _napResult = algo.compute();
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
    final name =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Utente';
    final pages = [
      _homeWidget(),
      CalendarPage(
        eventsMap: globalEvents,
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
              backgroundColor: Colors.transparent, // Rende l'AppBar trasparente
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
            DrawerHeader(child: Center(child: Text('Ciao $name'))),
            ListTile(title: const Text('THEME'), onTap: () {}),
            ListTile(title: const Text('LANGUAGE'), onTap: () {}),
            ListTile(title: const Text('OPTIONS'), onTap: () {}),
            ListTile(title: const Text('CREDITS'), onTap: () {}),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Seleziona il tempo di pisolino:",
                              style: TextStyle(fontSize: 16),
                            ),
                            Row(
                              children: [
                                _chooseAlarmButton(context, 10),
                                _chooseAlarmButton(context, 30),
                                _chooseAlarmButton(context, 90),
                              ],
                            ),
                          ],
                        ),
                      ),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // HOME WIDGET
  // -----------------------------------------------------------------------
  Widget _homeWidget() {
    final now = DateTime.now();
    final key = DateTime(now.year, now.month, now.day);
    final eventiOggi = List<MyEvent>.from(globalEvents[key] ?? [])
      ..sort((a, b) {
        final ma = a.startTime.hour * 60 + a.startTime.minute;
        final mb = b.startTime.hour * 60 + b.startTime.minute;
        return ma.compareTo(mb);
      });

    final sds = NapAlgorithm(
      sleepTarget: _sleepTarget,
      latencyMin: _latencyMin,
      sleepHistory: _sleepHistory,
      todayEvents: eventiOggi,
      wakeUpToday: null,
      averageSchoolWakeUp: _defaultWakeUp,
      today: now,
    ).computeSDS();

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
                const Text(
                  'Impegni di oggi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                _sdsReward(sds),
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
                        const Text(
                          'Nessun impegno per oggi',
                          style: TextStyle(color: Colors.grey),
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

  // widget for alarms
  Widget _chooseAlarmButton(BuildContext context, int? minutes) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(),

        onPressed: () {
          Navigator.pop(context);

          if (minutes != null) {
            print("Sveglia da $minutes minuti");
            NotificationService.setAlarm(minutes);
          } else {
            print("Apri personalizzata");
          }
        },
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
    final color = _zoneColor(r.zone);
    final label = r.zone == NapZone.orange
        ? 'Pisolino di emergenza'
        : 'Pisolino';
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
                  '${r.napEffectiveMin} min sonno  •  ${r.totalDisplayMin} min totali  •  ${r.scope}',
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
                          'Potresti avvertire stanchezza nei primi ~10 min dell\'attività successiva',
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
            const Text(
              'Zona Rossa • Troppo tardi per dormire',
              style: TextStyle(
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
          'Finestra di emergenza — solo per ridurre la sonnolenza momentanea',
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
    final label = isGreen ? 'Pisolino ideale' : 'Pisolino di Emergenza';
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
            TextSpan(text: '${r.scopeEmoji} ${r.scope}'),
            const TextSpan(text: '  •  dalle '),
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
          _dbRow(
            '🟢 Verde',
            '${NapAlgorithm.fmtMin(lim.greenStart)} → ${NapAlgorithm.fmtMin(lim.greenEnd)}',
            Colors.green,
          ),
          _dbRow(
            '🟡 Gialla',
            '${NapAlgorithm.fmtMin(lim.greenEnd)} → ${NapAlgorithm.fmtMin(lim.yellowEnd)}',
            Colors.amber,
          ),
          _dbRow(
            '🟠 Arancione',
            '${NapAlgorithm.fmtMin(lim.yellowEnd)} → ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
            Colors.orange.shade800,
          ),
          _dbRow(
            '🔴 Rossa',
            'oltre ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
            Colors.red,
          ),
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
    late String emoji, label;
    late Color color;
    if (sds < 0.5) {
      emoji = '🔋';
      label = 'Ottima forma';
      color = Colors.green;
    } else if (sds < 1.0) {
      emoji = '🙂';
      label = 'Leggero deficit';
      color = Colors.lightGreen;
    } else if (sds < 2.0) {
      emoji = '🥱';
      label = 'Debito moderato';
      color = Colors.orange.shade800;
    } else {
      emoji = '🚨';
      label = 'Debito severo';
      color = Colors.red;
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
}
