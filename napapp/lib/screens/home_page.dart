import 'dart:async';
import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'app_strings.dart';

import '../models/nap_models.dart';
import '../utils/time_utils.dart';
import '../utils/event_utils.dart';
import '../controllers/nap_controller.dart';
import '../algorithms/nap_algorithm.dart';
import '../services/foreground_service.dart';
import '../widgets/time_picker.dart';
import '../widgets/tutorial_dialog.dart';
import '../widgets/nap_card.dart';

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
  late NapController _controller;

  static const double _sleepTarget = 8.0;
  static const int _latencyMin = 10;
  static const TimeOfDay _defaultWakeUp = TimeOfDay(hour: 6, minute: 30);
  final List<SleepDay> _sleepHistory = [];

  Timer? _napTimer;

  List<_ListItem> _buildTimeline(List<MyEvent> eventi, NapResult? r) {
    final items = <_ListItem>[];

    for (final ev in eventi) {
      items.add(_ListItem.event(ev));
    }

    if (r != null &&
        r.zone != NapZone.red &&
        r.napEffectiveMin > 0 &&
        r.suggestedStart != null) {
      items.add(_ListItem.nap(r));
    }

    items.sort((a, b) => a.startMin.compareTo(b.startMin));

    return items;
  }

  void _refresh() {
    final now = DateTime.now();
    _controller.refresh(now);
  }

  @override
  void initState() {
    super.initState();

    _controller = NapController(
      sleepTarget: _sleepTarget,
      latencyMin: _latencyMin,
      sleepHistory: _sleepHistory,
      globalEvents: globalEvents,
      defaultWakeUp: _defaultWakeUp,
    );

    _refresh();

    _napTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(_refresh);
    });
  }

  @override
  void dispose() {
    _napTimer?.cancel();
    super.dispose();
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
          _controller = NapController(
            sleepTarget: _sleepTarget,
            latencyMin: _latencyMin,
            sleepHistory: _sleepHistory,
            globalEvents: globalEvents,
            defaultWakeUp: _defaultWakeUp,
          );
          _refresh();
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
                          leading: const Text(
                            '🇮🇹',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text('Italiano'),
                          selected: !_isEnglish,
                          onTap: () {
                            setState(() => _isEnglish = false);
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading: const Text(
                            '🇬🇧',
                            style: TextStyle(fontSize: 24),
                          ),
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
                Navigator.pop(
                  context,
                ); // chiude il drawer prima di aprire il dialog
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
                                    final totalMinutes =
                                        selectedDuration.inMinutes;
                                    final message = AppStrings(_isEnglish)
                                        .alarmSet(
                                          totalMinutes ~/ 60,
                                          totalMinutes % 60,
                                        );

                                    print("🚀 START SERVICE");

                                    await FlutterForegroundTask.startService(
                                      notificationTitle: '⏰ Sveglia attiva',
                                      notificationText: 'In corso...',
                                      callback: startCallback,
                                    );

                                    print("📡 SENDING DATA");

                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );

                                    FlutterForegroundTask.sendDataToTask(
                                      selectedDuration.inSeconds,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );

                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    AppStrings(_isEnglish).startAlarm,
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
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: s.navHome,
          ),
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
    final items = _buildTimeline(eventiOggi, _controller.napResult);

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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _sdsReward(_controller.sds),
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
          if (_controller.zoneLimits != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _debugZones(_controller.zoneLimits!),
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
                        ? NapCard(
                            r: items[i].napResult!,
                            isEnglish: _isEnglish,
                            fmtTOD: TimeUtils.fmtTOD,
                            zoneColor: _zoneColor,
                          )
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
          child: Icon(
            EventUtils.iconFromCategory(ev.category),
            color: ev.color,
            size: 28,
          ),
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
                '${TimeUtils.fmtTOD(ev.startTime)} - ${TimeUtils.fmtTOD(ev.endTime)}',
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
  // STRINGA PREDIZIONE
  // -----------------------------------------------------------------------
  Widget _predictionString() {
    final s = AppStrings(_isEnglish);
    final r = _controller.napResult;

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
    final start = TimeUtils.fmtTOD(r.suggestedStart!);

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
          _dbRow(
            s.zoneGreen,
            '${NapAlgorithm.fmtMin(lim.greenStart)} → ${NapAlgorithm.fmtMin(lim.greenEnd)}',
            Colors.green,
          ),
          _dbRow(
            s.zoneYellow,
            '${NapAlgorithm.fmtMin(lim.greenEnd)} → ${NapAlgorithm.fmtMin(lim.yellowEnd)}',
            Colors.amber,
          ),
          _dbRow(
            s.zoneOrange,
            '${NapAlgorithm.fmtMin(lim.yellowEnd)} → ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
            Colors.orange.shade800,
          ),
          _dbRow(
            s.zoneRed,
            '${s.zoneBeyond} ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
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
    final s = AppStrings(_isEnglish);
    late String emoji, label;
    late Color color;
    if (sds < 0.5) {
      emoji = '🔋';
      label = s.sdsGreat;
      color = Colors.green;
    } else if (sds < 1.0) {
      emoji = '🙂';
      label = s.sdsLight;
      color = Colors.lightGreen;
    } else if (sds < 2.0) {
      emoji = '🥱';
      label = s.sdsModerate;
      color = Colors.orange.shade800;
    } else {
      emoji = '🚨';
      label = s.sdsSevere;
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
      builder: (ctx) => TutorialDialog(pages: _tutorialPages),
    );
  }
}
