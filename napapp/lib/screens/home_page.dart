import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';

import 'app_strings.dart';

import '../models/nap_models.dart';
import '../utils/time_utils.dart';
import '../utils/timeline_utils.dart';
import '../controllers/nap_controller.dart';
import '../widgets/tutorial_dialog.dart';
import '../widgets/nap_card.dart';
import '../widgets/sds_reward.dart';
import '../widgets/debug_zones.dart';
import '../widgets/event_card.dart';
import '../widgets/prediction_box.dart';

// =============================================================================
// HOME PAGE
// =============================================================================
class HomePage extends StatefulWidget {
  final String? name;
  const HomePage({super.key, this.name});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NapController _controller;

  Map<DateTime, List<MyEvent>> globalEvents = {};
  Duration selectedDuration = const Duration(minutes: 10);
  int _pageIndex = 0;
  int selectedAlarm = 1;
  bool _isEnglish = false;
  Timer? _napTimer;
  final List<SleepDay> _sleepHistory = [];

  static const double _sleepTarget = 8.0;
  static const int _latencyMin = 10;
  static const TimeOfDay _defaultWakeUp = TimeOfDay(hour: 6, minute: 30);

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
            ListTile(
              title: const Text('TEMA'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text("Seleziona tema"),
                      content: StatefulBuilder(
                        builder: (context, setStateDialog) {
                          final themeProvider = context.watch<ThemeProvider>();
                          final selected = themeProvider.themeMode;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.system,
                                groupValue: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeProvider>().setTheme(
                                      value,
                                    );
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: const Text("Sistema"),
                              ),

                              RadioListTile<ThemeMode>(
                                value: ThemeMode.light,
                                groupValue: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeProvider>().setTheme(
                                      value,
                                    );
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: const Text("Chiaro"),
                              ),

                              RadioListTile<ThemeMode>(
                                value: ThemeMode.dark,
                                groupValue: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeProvider>().setTheme(
                                      value,
                                    );
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: const Text("Scuro"),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ThemeProvider>().toggleTheme();
          /*setState(() {
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
                                    AlarmChoiceButton(
                                      index: 1,
                                      minutes: 10,
                                      selectedIndex: selectedAlarm,
                                      onSelected: (index) {
                                        setState(() {
                                          selectedAlarm = index;
                                          selectedDuration = const Duration(
                                            minutes: 10,
                                          );
                                        });
                                      },
                                    ),
                                    AlarmChoiceButton(
                                      index: 2,
                                      minutes: 30,
                                      selectedIndex: selectedAlarm,
                                      onSelected: (index) {
                                        setState(() {
                                          selectedAlarm = index;
                                          selectedDuration = const Duration(
                                            minutes: 30,
                                          );
                                        });
                                      },
                                    ),
                                    AlarmChoiceButton(
                                      index: 3,
                                      minutes: 90,
                                      selectedIndex: selectedAlarm,
                                      onSelected: (index) {
                                        setState(() {
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
                                      notificationIcon: const NotificationIcon(
                                        metaDataName: 'ic_launcher',
                                      ),
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
                );*/
        },
        child: Icon(Icons.alarm),
      ),
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
    final items = buildTimeline(eventiOggi, _controller.napResult);
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
                SdsReward(sds: _controller.sds, isEnglish: _isEnglish),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // stringa predizione
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PredictionBox(
              r: _controller.napResult,
              isEnglish: _isEnglish,
            ),
          ),
          const SizedBox(height: 8),

          // debug zone
          if (_controller.zoneLimits != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DebugZonesBox(
                lim: _controller.zoneLimits!,
                isEnglish: _isEnglish,
              ),
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
                        : EventCard(ev: items[i].event!),
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
