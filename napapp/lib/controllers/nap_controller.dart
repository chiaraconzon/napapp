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
  TimeOfDay? wakeUpTime; // orario di sveglia recuperato dal wearable, per la UI

  NapController({
    required this.globalEvents,
  });

  /// Recupera i dati reali dal wearable via Impact e aggiorna napResult,
  /// zoneLimits e sds.
  ///
  /// I dati SDS / orario sveglia vengono recuperati al massimo una volta al
  /// giorno: se già presenti in cache (shared_preferences — persistente
  /// anche a riavvii dell'app e a ricreazioni di questo controller, es.
  /// quando si modifica il calendario) si riusano senza toccare la rete;
  /// altrimenti si prova il fetch da Impact. Se il wearable non ha ancora
  /// sincronizzato, non si salva nulla in cache, così si riprova
  /// automaticamente al prossimo refresh (tra un minuto).
  ///
  /// L'algoritmo (zone, orario pisolino suggerito) viene invece SEMPRE
  /// ricalcolato ad ogni chiamata, perché dipende dall'ora corrente e
  /// dagli eventi del calendario.
  Future<void> refresh(DateTime now) async {
    final key = DateTime(now.year, now.month, now.day);

    TimeOfDay? wakeUpToday;
    TimeOfDay? averageSchoolWakeUp;
    double? sdsReal;
    TimeOfDay? wakeUpForDebug;

    final cached = await _trySafeCacheRead(key);

    if (cached != null) {
      // Dati di oggi già recuperati in precedenza: li riusiamo senza richiamare il server.
      //va a vedere se è average o wakeuptime
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
      // Nessuna cache valida per oggi: proviamo a recuperare i dati freschi.
      try {
        final recentSleep = await RecentSleep.create();

        // SDS reale: getSleepDebt() restituisce minuti → converti in ore
        // (0.0 = nessun debito, 1.5 = debito moderato → coerente con NapAlgorithm)
        sdsReal = recentSleep.getSleepDebt() / 60.0;

        final hasRealData = recentSleep.wakeUpTime != null ||
            recentSleep.sleepDuration.any((d) => d != null);

        // isWakeUpTimeAlternative() == true  → l'orario è quello del giorno
        //   più recente (recent[0]), lo trattiamo come sveglia di "oggi".
        // isWakeUpTimeAlternative() == false → è stato necessario risalire
        //   a un giorno feriale precedente: lo trattiamo come media
        //   scolastica (usata dall'algoritmo solo la domenica).
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

        if (hasRealData) {
          // Dati reali trovati: li blocchiamo in cache per il resto del
          // giorno, così non richiamiamo più Impact fino a domani.
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
        // Altrimenti (wearable non ancora sincronizzato): non salviamo
        // nulla in cache, così si riprova automaticamente al prossimo
        // refresh, finché i dati non saranno disponibili.
      } catch (e) {
        // Server Impact non raggiungibile, non autorizzato o dati mancanti:
        // si ricade sui valori di fallback già previsti dall'algoritmo,
        // senza far crashare l'app. Si riproverà al prossimo refresh.
        debugPrint('Impact: impossibile recuperare i dati reali di sonno ($e)');
      }
    }

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

  // Lettura sicura della cache: se shared_preferences avesse un problema
  // (raro), trattiamo la situazione come "nessuna cache", non come errore
  // fatale — si passerà semplicemente al fetch da Impact qui sopra.
  Future<SleepCache?> _trySafeCacheRead(DateTime day) async {
    try {
      return await PreferencesService.getSleepCacheIfSameDay(day);
    } catch (e) {
      debugPrint('PreferencesService: impossibile leggere la cache ($e)');
      return null;
    }
  }
}
