import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/calendar_page.dart';

/// Dati di sonno (SDS + orario sveglia) recuperati da Impact e messi in
/// cache per il resto della giornata.
class SleepCache {
  final double sds;
  final TimeOfDay? wakeUpTime;

  /// true se wakeUpTime va usato come "media scolastica" (fallback, usato
  /// dall'algoritmo solo la domenica), false se è la sveglia reale di oggi.
  /// Rispecchia RecentSleep.isWakeUpTimeAlternative().
  final bool isAverageSchoolWakeUp;

  const SleepCache({
    required this.sds,
    this.wakeUpTime,
    this.isAverageSchoolWakeUp = false,
  });
}

/// Wrapper su shared_preferences per la cache giornaliera dei dati di
/// sonno (SDS + orario sveglia) recuperati dal server Impact.
///
/// SDS e orario sveglia arrivano dal wearable una volta al giorno.
/// Per evitare di richiamare il server Impact ogni minuto, il primo
/// fetch riuscito in una data giornata viene salvato qui e riusato
/// per il resto del giorno (vedi NapController.refresh).
class PreferencesService {
  PreferencesService._();

  static const _keySleepFetchDate = 'sleep_fetch_date'; // formato: yyyy-MM-dd
  static const _keySleepSds = 'sleep_cached_sds';
  static const _keySleepWakeHour = 'sleep_cached_wake_hour';
  static const _keySleepWakeMinute = 'sleep_cached_wake_minute';
  static const _keySleepIsAverage = 'sleep_cached_is_average';

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Salva i dati di sonno recuperati oggi da Impact.
  static Future<void> saveSleepCache({
    required DateTime fetchDate,
    required double sds,
    TimeOfDay? wakeUpTime,
    bool isAverageSchoolWakeUp = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySleepFetchDate, _dateKey(fetchDate));
    await prefs.setDouble(_keySleepSds, sds);
    await prefs.setBool(_keySleepIsAverage, isAverageSchoolWakeUp);
    if (wakeUpTime != null) {
      await prefs.setInt(_keySleepWakeHour, wakeUpTime.hour);
      await prefs.setInt(_keySleepWakeMinute, wakeUpTime.minute);
    } else {
      await prefs.remove(_keySleepWakeHour);
      await prefs.remove(_keySleepWakeMinute);
    }
  }

  /// Restituisce la cache SOLO se risale al giorno passato come parametro.
  /// Se è di un altro giorno (o non esiste ancora) restituisce null:
  /// vuol dire che serve un nuovo fetch da Impact.
  static Future<SleepCache?> getSleepCacheIfSameDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keySleepFetchDate);
    if (savedDate == null || savedDate != _dateKey(day)) return null;

    final sds = prefs.getDouble(_keySleepSds);
    if (sds == null) return null;

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

  // ---------------------------------------------------------------------
  // EVENTI CALENDARIO
  // ---------------------------------------------------------------------
  //
  // A differenza della sleep cache (valida solo per il giorno corrente),
  // gli eventi calendario vanno mantenuti indefinitamente: rappresentano
  // tutte le attività inserite dall'utente (passate e future), e devono
  // essere ricaricate identiche ad ogni riavvio dell'app.
  //
  // La mappa Map<DateTime, List<MyEvent>> viene serializzata in JSON come
  // Map<String, List<...>>, con le date normalizzate in chiavi "yyyy-MM-dd"
  // e i singoli eventi convertiti tramite MyEvent.toJson()/fromJson().

  static const _keyCalendarEvents = 'calendar_events';
  static final DateFormat _eventDayFormat = DateFormat('yyyy-MM-dd');

  /// Salva l'intera mappa degli eventi calendario. Va chiamato ogni volta
  /// che la mappa viene modificata (aggiunta, modifica, eliminazione di
  /// un evento), così le modifiche sopravvivono alla chiusura dell'app.
  static Future<void> saveCalendarEvents(
    Map<DateTime, List<MyEvent>> events,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> serializable = {};
    events.forEach((day, eventList) {
      serializable[_eventDayFormat.format(day)] =
          eventList.map((e) => e.toJson()).toList();
    });

    await prefs.setString(_keyCalendarEvents, jsonEncode(serializable));
  }

  /// Ricarica la mappa degli eventi calendario salvata in precedenza
  /// (tipicamente all'avvio dell'app). Restituisce una mappa vuota se non
  /// c'è ancora nulla di salvato o se i dati risultano corrotti, così
  /// l'app non crasha mai per questo.
  static Future<Map<DateTime, List<MyEvent>>> loadCalendarEvents() async {
    final Map<DateTime, List<MyEvent>> result = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCalendarEvents);
      if (raw == null || raw.isEmpty) return result;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      decoded.forEach((dayString, rawList) {
        try {
          final day = _eventDayFormat.parse(dayString);
          final events = (rawList as List)
              .map((j) => MyEvent.fromJson(j as Map<String, dynamic>))
              .toList();
          result[day] = events;
        } catch (e) {
          // Un singolo giorno corrotto non deve invalidare tutto il resto:
          // lo saltiamo e proseguiamo con gli altri giorni.
        }
      });
    } catch (e) {
      // SharedPreferences non disponibile o JSON corrotto: si riparte da
      // una mappa vuota invece di far crashare l'app all'avvio.
    }

    return result;
  }

  /// Rimuove tutti gli eventi calendario salvati (es. per un futuro
  /// logout o reset dei dati).
  static Future<void> clearCalendarEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCalendarEvents);
  }
}