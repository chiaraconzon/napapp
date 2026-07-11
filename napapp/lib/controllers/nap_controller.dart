import 'package:flutter/material.dart';
import '../algorithms/nap_algorithm.dart';
import '../models/nap_models.dart';
import '../models/sleep.dart';
import '../services/preferences_service.dart';
import '../screens/calendar_page.dart';

class NapController {
  final Map<DateTime, List<MyEvent>> globalEvents;

  NapResult? napResult;
  ZoneLimits? zoneLimits;
  double sds = 0.0;
  TimeOfDay? wakeUpTime; // Wake-up time retrieved from wearable

  NapController({
    required this.globalEvents,
  });

   // Fetches real data from the wearable via Impact and updates the nap state.
  
  // Wearable data (SDS/wake-up time) is fetched at most once a day:
  // - If found in local cache (SharedPreferences), it uses it.
  // - If not, it attempts a network fetch. If the wearable hasn't synced yet, 
  //   it skips caching so it can retry on the next refresh. 
  // The algorithm itself (zones, suggested nap time) is always recomputed 
  // on every call since it relies on the current time and calendar events.
  Future<void> refresh(DateTime now) async {
    final key = DateTime(now.year, now.month, now.day); // Use today's date as cache key

    TimeOfDay? wakeUpToday;
    TimeOfDay? averageSchoolWakeUp;
    double? sdsReal;
    TimeOfDay? wakeUpForDebug;

    //Try to read from local cache to avoid unnecessary network calls
    final cached = await _trySafeCacheRead(key);

    if (cached != null) {
      // Cache hit: Use previously fetched data for today
      sdsReal = cached.sds;
      wakeUpForDebug = cached.wakeUpTime;
      if (cached.wakeUpTime != null) {
        if (cached.isAverageSchoolWakeUp) {
          averageSchoolWakeUp = cached.wakeUpTime;
        } else {
          wakeUpToday = cached.wakeUpTime;
        }
      }
    } else {
      // Cache miss: Fetch fresh data from the Impact server
      try {
        final recentSleep = await RecentSleep.create();

        // Convert Sleep Debt from minutes to hours (0.0 = no debt)
        sdsReal = recentSleep.getSleepDebt() / 60.0;

        final hasRealData = recentSleep.wakeUpTime != null ||
            recentSleep.sleepDuration.any((d) => d != null);

        // Determine if the wake-up time is from today or a past school day average (take the value of a past day)
        bool isAverage = false;
        if (recentSleep.wakeUpTime != null) {
          final tod = TimeOfDay.fromDateTime(recentSleep.wakeUpTime!);
          wakeUpForDebug = tod;
          isAverage = !recentSleep.isWakeUpTimeAlternative();
          if (isAverage) {
            averageSchoolWakeUp = tod;
          } else {
            wakeUpToday = tod;
          }
        }

        //Cache the fetched data if it's valid, locking it for the rest of the day
        if (hasRealData) {
          try {
            await PreferencesService.saveSleepCache(
              fetchDate: key,
              sds: sdsReal,
              wakeUpTime: wakeUpForDebug,
              isAverageSchoolWakeUp: isAverage,
            );
          } catch (e) {
            debugPrint(
              'PreferencesService: impossibile salvare la cache ($e)',
            );
          }
        }
      } catch (e) {
        // Fallback: If network fails, silently proceed so the algorithm can use defaults
        debugPrint('Impact: impossibile recuperare i dati reali di sonno ($e)');
      }
    }

    // Recompute the nap algorithm with the latest data and time
    final algo = NapAlgorithm(
      todayEvents: globalEvents[key] ?? [],
      wakeUpToday: wakeUpToday,
      averageSchoolWakeUp: averageSchoolWakeUp,
      today: now,
      sdsOverride: sdsReal,
    );

    napResult = algo.compute();
    zoneLimits = algo.computeZoneLimits();
    sds = algo.computeSDS();
    wakeUpTime = wakeUpForDebug;
  }

  //Helper to safely read cache without crashing the app on SharedPreferences errors
  Future<SleepCache?> _trySafeCacheRead(DateTime day) async {
    try {
      return await PreferencesService.getSleepCacheIfSameDay(day);
    } catch (e) {
      debugPrint('PreferencesService: impossibile leggere la cache ($e)');
      return null;
    }
  }
}
