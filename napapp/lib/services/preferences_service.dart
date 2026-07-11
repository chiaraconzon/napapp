import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/calendar_page.dart';

// Stores cached sleep information retrieved from IMPACT (sds and wakeupTime)
class SleepCache {
  final double sds;
  final TimeOfDay? wakeUpTime;

  // Indicates whether wake-up time is an estimated school average
  final bool isAverageSchoolWakeUp;

  const SleepCache({
    required this.sds,
    this.wakeUpTime,
    this.isAverageSchoolWakeUp = false,
  });
}

// Service class that manages local data storage
// Uses SharedPreferences to save data between app sessions
class PreferencesService {
  PreferencesService._();

  static const _keySleepFetchDate = 'sleep_fetch_date'; // formato: yyyy-MM-dd
  static const _keySleepSds = 'sleep_cached_sds';
  static const _keySleepWakeHour = 'sleep_cached_wake_hour';
  static const _keySleepWakeMinute = 'sleep_cached_wake_minute';
  static const _keySleepIsAverage = 'sleep_cached_is_average';

  // Converts DateTime into storage format (yyyy-MM-dd)
  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // Saves daily sleep data retrieved from IMPACT
  static Future<void> saveSleepCache({
    required DateTime fetchDate,
    required double sds,
    TimeOfDay? wakeUpTime,
    bool isAverageSchoolWakeUp = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Store sleep information locally
    await prefs.setString(_keySleepFetchDate, _dateKey(fetchDate));
    await prefs.setDouble(_keySleepSds, sds);
    await prefs.setBool(_keySleepIsAverage, isAverageSchoolWakeUp);
    // Store wake-up time if available
    if (wakeUpTime != null) {
      await prefs.setInt(_keySleepWakeHour, wakeUpTime.hour);
      await prefs.setInt(_keySleepWakeMinute, wakeUpTime.minute);
    } else {
      await prefs.remove(_keySleepWakeHour);
      await prefs.remove(_keySleepWakeMinute);
    }
  }

  // Loads sleep cache only if it belongs to the requested day
  static Future<SleepCache?> getSleepCacheIfSameDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keySleepFetchDate);
    // Return null if cache is missing or outdated
    if (savedDate == null || savedDate != _dateKey(day)) return null;

    final sds = prefs.getDouble(_keySleepSds);
    if (sds == null) return null;
    // Restore saved wake-up time
    final h = prefs.getInt(_keySleepWakeHour);
    final m = prefs.getInt(_keySleepWakeMinute);
    final wakeUpTime = (h != null && m != null)
        ? TimeOfDay(hour: h, minute: m)
        : null;
    final isAverage = prefs.getBool(_keySleepIsAverage) ?? false;

    return SleepCache(
      sds: sds,
      wakeUpTime: wakeUpTime,
      isAverageSchoolWakeUp: isAverage,
    );
  }

  //CALENDAR EVENTS
  // calendar events are stored indefinitely.
<<<<<<< HEAD
  // They contain all past and future user activities and must be fully 
=======
  // They contain all past and future user activities and must be fully
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
  // restored on every app restart.
  //
  // The Map<DateTime, List<MyEvent>> is serialized to JSON as
  // Map<String, List<dynamic>>, using "yyyy-MM-dd" strings as keys.
  static const _keyCalendarEvents = 'calendar_events';
  static final DateFormat _eventDayFormat = DateFormat('yyyy-MM-dd');

  // Saves all calendar events in JSON format
  static Future<void> saveCalendarEvents(
    Map<DateTime, List<MyEvent>> events,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert events map into JSON-compatible format
    final Map<String, dynamic> serializable = {};
    events.forEach((day, eventList) {
      serializable[_eventDayFormat.format(day)] = eventList
          .map((e) => e.toJson())
          .toList();
    });

    await prefs.setString(_keyCalendarEvents, jsonEncode(serializable));
  }

<<<<<<< HEAD
 // Loads saved calendar events from local storage
=======
  // Loads saved calendar events from local storage
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
  static Future<Map<DateTime, List<MyEvent>>> loadCalendarEvents() async {
    final Map<DateTime, List<MyEvent>> result = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCalendarEvents);
      // Return empty calendar if no data exists
      if (raw == null || raw.isEmpty) return result;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      // Convert stored JSON back into MyEvent objects
      decoded.forEach((dayString, rawList) {
        try {
          final day = _eventDayFormat.parse(dayString);
          final events = (rawList as List)
              .map((j) => MyEvent.fromJson(j as Map<String, dynamic>))
              .toList();
          result[day] = events;
        } catch (e) {
          // Ignore invalid entries
        }
      });
    } catch (e) {
      // Return empty data if storage is unavailable
    }

    return result;
  }

  // Removes all saved calendar events (es. for a future logout)
  static Future<void> clearCalendarEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCalendarEvents);
  }

  // UI Preferences (theme and language)
  static const _keyThemeMode = 'pref_theme_mode';
  static const _keyIsEnglish = 'pref_is_english';

  // Saves selected app theme (system/light/dark).
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  // Loads saved theme or returns system default
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  // Saves selected language preference (true = inglese, false = italiano).
  static Future<void> saveIsEnglish(bool isEnglish) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsEnglish, isEnglish);
  }

  // Loads saved language preference
  static Future<bool> loadIsEnglish() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsEnglish) ?? false;
  }
<<<<<<< HEAD
=======

  static const _profileNameKey = 'profile_name';

  static Future<void> saveProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, name);
  }

  static Future<String> loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileNameKey) ?? 'Utente';
  }

  static const _profileImageKey = 'profile_image';

  static Future<void> saveProfileImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_profileImageKey, index);
  }

  static Future<int> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileImageKey) ?? 0;
  }
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
}
