import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:provider/provider.dart';

import 'calendar_page.dart';
import 'stats_page.dart';
import 'login_page.dart';
import 'app_strings.dart';
import 'profile_page.dart';

import '../models/nap_models.dart';
import '../models/sleep.dart';
import '../utils/time_utils.dart';
import '../utils/timeline_utils.dart';
import '../controllers/nap_controller.dart';
import '../services/preferences_service.dart';
import '../services/impact.dart';
import '../widgets/home/tutorial_dialog.dart';
import '../widgets/home/nap_card.dart';
import '../widgets/home/sds_reward.dart';
import '../widgets/home/debug_zones.dart';
import '../widgets/home/event_card.dart';
import '../widgets/home/prediction_box.dart';
import '../widgets/home/time_picker.dart';
import '../widgets/home/choose_time.dart';
import '../providers/theme_provider.dart';
import '../constrains/bibliography.dart';

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
  String _profileName = "Utente";
  int _profileImage = 0;

  Map<DateTime, SleepData> globalSleepData = {};
  List<SleepData> globalSleepDataList = [];

  Future<void> _loadProfileName() async {
    final saved = await PreferencesService.loadProfileName();

    if (!mounted) return;

    setState(() {
      _profileName = saved;
    });
  }

  Future<void> _loadProfileImage() async {
    final image = await PreferencesService.loadProfileImage();

    if (!mounted) return;

    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _loadProfile() async {
    final name = await PreferencesService.loadProfileName();
    final image = await PreferencesService.loadProfileImage();

    setState(() {
      _profileName = name;
      _profileImage = image;
    });
  }

  Map<DateTime, SleepData> globalSleepData = {};
  List<SleepData> globalSleepDataList = [];

  // async perché NapController.refresh() chiama il wearable via await
  Future<void> _refresh() async {
    final now = DateTime.now().subtract(Duration(days: 1));
    await _controller.refresh(now);
    if (mounted) setState(() {});
  }

  // Metodo async per prendere 30 giorni di dati del sonno dal server Impact
  Future<void> _loadSleepData() async {
    List<SleepData> listData = await Impact.getN_DaysFromMostRecent(30);
    // Converte lista in mappa -> CHANGE: resta List
    Map<DateTime, SleepData> mapData = {
<<<<<<< HEAD
      for (var elem in listData) elem.date : elem
=======
      for (var elem in listData) elem.date: elem,
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
    };

    setState(() {
      globalSleepData = mapData;
      globalSleepDataList = listData;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = NapController(globalEvents: globalEvents);

    _refresh(); // fire-and-forget: aggiorna appena i dati arrivano
    _loadPersistedEvents(); // fire-and-forget: ricarica gli eventi salvati
    _loadPersistedLanguage(); // fire-and-forget: ricarica la lingua salvata

    _loadSleepData();
<<<<<<< HEAD

=======
    _loadProfileName(); // ricarica il nome salvato
    _loadProfileImage(); // ricarica imm profilo
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
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
    final pages = [
      _homeWidget(),
      CalendarPage(
        eventsMap: globalEvents,
        isEnglish: _isEnglish,
        onEventsUpdated: (m) => setState(() {
          globalEvents = m;
          _controller = NapController(globalEvents: globalEvents);
          _refresh();
          // Persiste su SharedPreferences ogni modifica al calendario
          // (aggiunta/modifica/eliminazione evento), così viene ricaricata
          // alla riapertura dell'app. Fire-and-forget, come _refresh().
          PreferencesService.saveCalendarEvents(m);
        }),
      ),
<<<<<<< HEAD
      StatsPage(
        sleepData: globalSleepDataList,
        sds: _controller.sds
      ),
=======
      StatsPage(sleepData: globalSleepDataList, sds: _controller.sds),
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _pageIndex == 0
          ? AppBar(
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
            )
          : null,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        [
                          "assets/profile_imm/imm1.png",
                          "assets/profile_imm/imm2.png",
                          "assets/profile_imm/imm3.png",
                        ][_profileImage],
                      ),
                    ),

                    const SizedBox(width: 15),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ciao,",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        Text(
                          _profileName.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('UTENTE'),
              onTap: () async {
                Navigator.pop(context);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      currentName: _profileName,
                      currentImage: _profileImage,
                    ),
                  ),
                );

                if (result == true) {
                  _loadProfileName();
                }

                if (result == true) {
                  await _loadProfile();
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('TEMA'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : null,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Seleziona tema:"),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
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
              leading: const Icon(Icons.language_outlined),
              title: const Text('LINGUA'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Seleziona lingua:"),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
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
                                Navigator.pop(ctx);
                              },
                              title: const Text('Italiano'),
                            ),
                            RadioListTile<bool>(
                              value: true,
                              groupValue: _isEnglish,
                              onChanged: (_) {
                                setState(() => _isEnglish = true);
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
              title: const Text('TUTORIAL'),
              onTap: () {
                Navigator.pop(context);
                _showTutorial(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('BIBLIOGRAFIA'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surface
                          : null,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bibliography:"),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: bibliography.length,
                          itemBuilder: (context, index) {
                            final item = bibliography[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(item.citation),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
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
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                final idealDuration = Duration(
                  minutes: _controller.napResult?.napEffectiveMin ?? 10,
                );

                setState(() {
                  selectedAlarm = 0;
                  selectedDuration = idealDuration;
                });

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),

                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.surface,

                              borderRadius: BorderRadius.circular(28),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(20),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Text(
                                        s.selectAlarmTitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),

                                      IconButton(
                                        onPressed: () => Navigator.pop(context),

                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // CONSIGLIO ALGORITMO
                                  Container(
                                    width: double.infinity,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.12),

                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    child: Column(
                                      children: [
                                        const Text(
                                          "Pisolino consigliato",

                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "${idealDuration.inMinutes} minuti",

                                          style: TextStyle(
                                            fontSize: 20,

                                            fontWeight: FontWeight.bold,

                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ROTELLE
                                  ChooseTime(
                                    duration: selectedDuration,

                                    onChanged: (duration) {
                                      setDialogState(() {
                                        selectedDuration = duration;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 6),

                                  // PRESET
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,

                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 10,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 10),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 10,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          const Text(
                                            "Boost",

                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),

                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 30,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 30),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 30,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          const Text(
                                            "Memoria",

                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),

                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 90,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 90),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 90,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          const Text(
                                            "Recupero",

                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // BOTTONE
                                  SizedBox(
                                    width: double.infinity,

                                    height: 52,

                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.alarm),

                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              s.alarmTimerStarted(
                                                selectedDuration.inMinutes,
                                              ),
                                            ),
                                          ),
                                        );

                                        FlutterAlarmClock.createTimer(
                                          length: selectedDuration.inSeconds,
                                        );

                                        Navigator.pop(context);
                                      },

                                      label: const Text(
                                        "Avvia pisolino",

                                        style: TextStyle(
                                          fontSize: 18,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.alarm),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Colore dell'icona selezionata
        unselectedItemColor: Colors.grey, // Colore delle icone NON selezionate
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
              height: 3, // Spessore della riga
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(
                  0.4,
                ), // Colore neutro semitrasparente
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
                wakeUpTime:
                    _controller.wakeUpTime, // ← da aggiungere in NapController
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

                            onRequestNewNap: () async {
                              await _refresh();

                              setState(() {});
                            },
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
      builder: (ctx) =>
          TutorialDialog(pages: AppStrings(_isEnglish).tutorialPages),
    );
  }
}
