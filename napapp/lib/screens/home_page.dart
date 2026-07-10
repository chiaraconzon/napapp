import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:provider/provider.dart';

import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';
import 'app_strings.dart';

import '../models/nap_models.dart';
import '../utils/time_utils.dart';
import '../utils/timeline_utils.dart';
import '../controllers/nap_controller.dart';
import '../services/preferences_service.dart';
import '../widgets/tutorial_dialog.dart';
import '../widgets/nap_card.dart';
import '../widgets/sds_reward.dart';
import '../widgets/debug_zones.dart';
import '../widgets/event_card.dart';
import '../widgets/prediction_box.dart';
import '../widgets/time_picker.dart';
import '../providers/theme_provider.dart';

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


  // async perché NapController.refresh() chiama il wearable via await
  Future<void> _refresh() async {
    final now = DateTime.now().subtract(Duration(days: 1));
    await _controller.refresh(now);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _controller = NapController(
      globalEvents: globalEvents,
    );

    _refresh(); // fire-and-forget: aggiorna appena i dati arrivano
    _loadPersistedEvents(); // fire-and-forget: ricarica gli eventi salvati
    _loadPersistedLanguage(); // fire-and-forget: ricarica la lingua salvata

    _napTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (mounted) await _refresh();
    });
  }

  /// Ricarica dal disco (SharedPreferences) gli eventi calendario salvati
  /// nelle sessioni precedenti e li ripopola in [globalEvents], così le
  /// attività inserite dall'utente sopravvivono alla chiusura dell'app.
  ///
  /// Si mantiene lo stesso oggetto Map (clear + addAll) invece di
  /// riassegnare globalEvents, così il riferimento passato a NapController
  /// resta valido; il controller viene comunque ricreato per coerenza con
  /// il resto del codice, e si ricalcola subito la predizione.
  Future<void> _loadPersistedEvents() async {
    final loaded = await PreferencesService.loadCalendarEvents();
    if (!mounted || loaded.isEmpty) return;

    setState(() {
      globalEvents
        ..clear()
        ..addAll(loaded);
      _controller = NapController(globalEvents: globalEvents);
    });

    await _refresh();
  }

  /// Ricarica dal disco (SharedPreferences) la lingua scelta nella sessione
  /// precedente, così l'app riparte già nella lingua giusta invece di
  /// tornare sempre all'italiano di default.
  Future<void> _loadPersistedLanguage() async {
    final saved = await PreferencesService.loadIsEnglish();
    if (!mounted) return;
    setState(() => _isEnglish = saved);
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
            globalEvents: globalEvents,
            );
          _refresh();
          // Persiste su SharedPreferences ogni modifica al calendario
          // (aggiunta/modifica/eliminazione evento), così viene ricaricata
          // alla riapertura dell'app. Fire-and-forget, come _refresh().
          PreferencesService.saveCalendarEvents(m);
        }),
      ),
      StatsPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _pageIndex == 1
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SdsReward(sds: _controller.sds, isEnglish: _isEnglish),
                ),
              ],
            ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Text(s.hello(name)))),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(s.themeLabel),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text(s.selectTheme),
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
                                    context.read<ThemeProvider>().setTheme(value);
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: Text(s.themeSystem),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.light,
                                groupValue: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeProvider>().setTheme(value);
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: Text(s.themeLight),
                              ),
                              RadioListTile<ThemeMode>(
                                value: ThemeMode.dark,
                                groupValue: selected,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeProvider>().setTheme(value);
                                    Navigator.pop(ctx);
                                  }
                                },
                                title: Text(s.themeDark),
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
              leading: const Icon(Icons.language_outlined),
              title: Text(s.languageLabel),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.selectLanguage),
                    content: StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<bool>(
                              value: false,
                              groupValue: _isEnglish,
                              onChanged: (_) {
                                setState(() => _isEnglish = false);
                                PreferencesService.saveIsEnglish(false);
                                Navigator.pop(ctx);
                              },
                              title: const Text('Italiano'),
                            ),
                            RadioListTile<bool>(
                              value: true,
                              groupValue: _isEnglish,
                              onChanged: (_) {
                                setState(() => _isEnglish = true);
                                PreferencesService.saveIsEnglish(true);
                                Navigator.pop(ctx);
                              },
                              title: const Text('English'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(s.tutorialLabel),
              onTap: () {
                Navigator.pop(context);
                _showTutorial(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(s.creditsLabel),
              onTap: () {},
            ),
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
          setState(() => selectedAlarm = 0);

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.selectAlarmTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AlarmCircleTimer(
                                  duration: const Duration(minutes: 10),
                                  selected:
                                      selectedDuration ==
                                      const Duration(minutes: 10),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDuration = const Duration(
                                        minutes: 10,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AlarmCircleTimer(
                                  duration: const Duration(minutes: 30),
                                  selected:
                                      selectedDuration ==
                                      const Duration(minutes: 30),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDuration = const Duration(
                                        minutes: 30,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AlarmCircleTimer(
                                  duration: const Duration(minutes: 90),
                                  selected:
                                      selectedDuration ==
                                      const Duration(minutes: 90),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDuration = const Duration(
                                        minutes: 90,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    s.alarmTimerStarted(selectedDuration.inMinutes),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              FlutterAlarmClock.createTimer(
                                length: selectedDuration.inSeconds,
                              );

                              Navigator.pop(context);
                            },
                            child: Text(AppStrings(_isEnglish).startAlarm),
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
        child: const Icon(Icons.alarm),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
        selectedItemColor: Theme.of(context).colorScheme.primary, // Colore dell'icona selezionata
        unselectedItemColor: Colors.grey,                         // Colore delle icone NON selezionate
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
    final now = DateTime.now().subtract(Duration(days: 1));
    final key = DateTime(now.year, now.month, now.day);
    final eventiOggi = List<MyEvent>.from(globalEvents[key] ?? [])
      ..sort((a, b) {
        final ma = a.startTime.hour * 60 + a.startTime.minute;
        final mb = b.startTime.hour * 60 + b.startTime.minute;
        return ma.compareTo(mb);
      });

    final items = buildTimeline(eventiOggi, _controller.napResult);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stringa predizione
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
            child: PredictionBox(
              r: _controller.napResult,
              isEnglish: _isEnglish,
            ),
          ),
          
          // NUOVO ELEMENTO: Righetta corta centrata divisoria
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 150, // Lunghezza della riga
              height: 3,  // Spessore della riga
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4), // Colore neutro semitrasparente
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Debug zone
          if (_controller.zoneLimits != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DebugZonesBox(
                lim: _controller.zoneLimits!,
                isEnglish: _isEnglish,
                wakeUpTime: _controller.wakeUpTime, // ← da aggiungere in NapController
                sds: _controller.sds,
              ),
            ),
          if (_controller.zoneLimits != null) const SizedBox(height: 8),

          // Lista cronologica degli impegni
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
                        : EventCard(ev: items[i].event!, isEnglish: _isEnglish),
                  ),
          ),
        ],
      ),
    );
  }
  
  // ---------------------------------------------------------------------------
  // TUTORIAL
  // ---------------------------------------------------------------------------
void _showTutorial(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => TutorialDialog(pages: AppStrings(_isEnglish).tutorialPages),
  );
}
}