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

// State management for the home page
class _HomePageState extends State<HomePage> {
  // Core controllers and state variables
  late NapController _controller;

  // Stores user calendar events
  Map<DateTime, List<MyEvent>> globalEvents = {};
  // Timer and UI state
  Duration selectedDuration = const Duration(minutes: 10);
  int _pageIndex = 0;
  int selectedAlarm = 1;
  bool _isEnglish = false;
  Timer? _napTimer;
  // Profile state
  String _profileName = "Utente";
  int _profileImage = 0;

  // Sleep data retrieved from IMPACT server
  Map<DateTime, SleepData> globalSleepData = {};
  List<SleepData> globalSleepDataList = [];

  // Loads saved user name from local storage
  Future<void> _loadProfileName() async {
    final saved = await PreferencesService.loadProfileName();

    if (!mounted) return;

    setState(() {
      _profileName = saved;
    });
  }

   // Loads saved profile image from local storage
  Future<void> _loadProfileImage() async {
    final image = await PreferencesService.loadProfileImage();

    if (!mounted) return;

    setState(() {
      _profileImage = image;
    });
  }

  // Loads complete profile information
  Future<void> _loadProfile() async {
    final name = await PreferencesService.loadProfileName();
    final image = await PreferencesService.loadProfileImage();

    setState(() {
      _profileName = name;
      _profileImage = image;
    });
  }

  // Refreshes nap algorithm using the latest sleep data
  Future<void> _refresh() async {
    final now = DateTime.now().subtract(Duration(days: 1));
    await _controller.refresh(now);
    // Update UI after new data is available
    if (mounted) setState(() {});
  }

  // Downloads recent sleep history from IMPACT server
  Future<void> _loadSleepData() async {
    // Retrieves the last 30 days of sleep data
    List<SleepData> listData = await Impact.getN_DaysFromMostRecent(30);
    // Map dates to SleepData objects
    Map<DateTime, SleepData> mapData = {
      for (var elem in listData) elem.date: elem,
    };

    setState(() {
      globalSleepData = mapData;
      globalSleepDataList = listData;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _controller = NapController(globalEvents: globalEvents);

    // Load initial app data
    _refresh(); 
    _loadPersistedEvents(); 
    _loadPersistedLanguage(); 

    _loadSleepData();
    _loadProfileName(); 
    _loadProfileImage(); 
    // Periodically update nap suggestions (every minute)
    _napTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (mounted) await _refresh();
    });
  }

  // Restore calendar events from SharedPreferences
  // Ensures user activities survive app restarts
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

  // Restore language preference from SharedPreferences
  Future<void> _loadPersistedLanguage() async {
    final saved = await PreferencesService.loadIsEnglish();
    if (!mounted) return;
    setState(() => _isEnglish = saved);
  }

  // Cleanup resources
  @override
  void dispose() {
    _napTimer?.cancel();
    super.dispose();
  }

  // Map NapZone enums to specific UI colors
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
    // Define the 3 main app views
    final pages = [
      _homeWidget(),
      CalendarPage(
        eventsMap: globalEvents,
        isEnglish: _isEnglish,
        // Triggered when calendar is modified
        onEventsUpdated: (m) => setState(() {
          globalEvents = m;
          _controller = NapController(globalEvents: globalEvents);
          _refresh();
          // Save calendar changes to disk
          PreferencesService.saveCalendarEvents(m);
        }),
      ),
      StatsPage(
        sleepData: globalSleepDataList,
        sds: _controller.sds,
        isEnglish: _isEnglish,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      // Top AppBar (visible only on Home tab)
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
              // SDS Score Badge
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SdsReward(sds: _controller.sds, isEnglish: _isEnglish),
                ),
              ],
            )
          : null,
      // Side Navigation Drawer
      drawer: Drawer(
        child: Column(
          children: [
            // Custom Profile Header
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
                    // Profile Avatar
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
                    // Greeting and Name
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.greetingLabel,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith( color: Colors.black,),
                        ),

                        Text(
                          _profileName.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold,color: Colors.black,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Profile Edit Menu Item
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(s.userLabel),
              onTap: () async {
                Navigator.pop(context);

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      currentName: _profileName,
                      currentImage: _profileImage,
                      isEnglish: _isEnglish,
                    ),
                  ),
                );

                // Reload profile data if changed
                if (result == true) {
                  _loadProfileName();
                }

                // Theme Selection Menu Item
                if (result == true) {
                  await _loadProfile();
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(s.themeLabel),
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
                          Text('${s.selectTheme}:', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                                title: Text(s.themeSystem),
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
                                title: Text(s.themeLight),
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
            // Language Selection Menu Item
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(s.languageLabel),
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
                        Text('${s.selectLanguage}:', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                              title: Text(s.languageItalian),
                            ),
                            RadioListTile<bool>(
                              value: true,
                              groupValue: _isEnglish,
                              onChanged: (_) {
                                setState(() => _isEnglish = true);
                                Navigator.pop(ctx);
                              },
                              title: Text(s.languageEnglish),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // App Tutorial
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(s.tutorialLabel),
              onTap: () {
                Navigator.pop(context);
                _showTutorial(context);
              },
            ),

            // Bibliography 
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(s.bibliographyLabel),
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
                          Text(s.bibliographyDialogTitle),
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

            // Logout Action
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
      // Floating Alarm Button (Visible only on Home page)
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Determine ideal nap duration from algorithm
                final idealDuration = Duration(
                  minutes: _controller.napResult?.napEffectiveMin ?? 10,
                );

                setState(() {
                  selectedAlarm = 0;
                  selectedDuration = idealDuration +const Duration(minutes: 10);
                });

                // Show Alarm Configuration Dialog
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
                                  // Dialog Header
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

                                  // ALGORITHM RECOMMENDATION BOX
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
                                        Text(
                                          s.recommendedNap,

                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          s.napMinutes(idealDuration.inMinutes + 10),

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

                                  // CUSTOM TIME PICKER WHEEL
                                  ChooseTime(
                                    duration: selectedDuration,

                                    onChanged: (duration) {
                                      setDialogState(() {
                                        selectedDuration = duration;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 6),

                                  // PRESET ALARM BUTTONS
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,

                                    children: [
                                      // 10+10 Min Preset
                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 20,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 20),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 20,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            s.presetReflexes,

                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),

                                      // 30+10 Min Preset
                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 40,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 40),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 40,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            s.presetFocus,

                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),

                                      // 90+10 Min Preset
                                      Column(
                                        mainAxisSize: MainAxisSize.min,

                                        children: [
                                          SizedBox(
                                            width: 78,
                                            height: 78,

                                            child: AlarmCircleTimer(
                                              duration: const Duration(
                                                minutes: 100,
                                              ),

                                              selected:
                                                  selectedDuration ==
                                                  const Duration(minutes: 100),

                                              onTap: () {
                                                setDialogState(() {
                                                  selectedDuration =
                                                      const Duration(
                                                        minutes: 100,
                                                      );
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            s.presetRecovery,

                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // START ALARM BUTTON
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

                                        // Trigger OS native alarm
                                        FlutterAlarmClock.createTimer(
                                          length: selectedDuration.inSeconds,
                                        );

                                        Navigator.pop(context);
                                      },

                                      label: Text(
                                        s.startNapButton,

                                        style: const TextStyle(
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() => _pageIndex = i),
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Color of the selected icon
        unselectedItemColor: Colors.grey, // Color of the not selected icons
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
    // Fetch and sort today's events chronologically
    final eventiOggi = List<MyEvent>.from(globalEvents[key] ?? [])
      ..sort((a, b) {
        final ma = a.startTime.hour * 60 + a.startTime.minute;
        final mb = b.startTime.hour * 60 + b.startTime.minute;
        return ma.compareTo(mb);
      });

    // Generate chronological timeline mapping events alongside predicted nap
    final items = buildTimeline(eventiOggi, _controller.napResult);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nap prediction textual display
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
            child: PredictionBox(
              r: _controller.napResult,
              isEnglish: _isEnglish,
            ),
          ),

          // Visual horizontal separator
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 150, // separator length
              height: 3, 
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(
                  0.4,
                ), 
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
                    _controller.wakeUpTime, 
                sds: _controller.sds,
              ),
            ),
          if (_controller.zoneLimits != null) const SizedBox(height: 8),

          // timeline of tasks and naps
          Expanded(
            child: items.isEmpty
                // Empty state view
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
                // Populated agenda view
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => items[i].isNap
                        // Render algorithm's nap suggestion block
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
                        // Render standard user event
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
  // Display the tutorial dialog
  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          TutorialDialog(pages: AppStrings(_isEnglish).tutorialPages),
    );
  }
}
