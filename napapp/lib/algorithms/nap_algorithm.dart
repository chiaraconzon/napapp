import 'package:flutter/material.dart';
import '../models/nap_models.dart';
import '../screens/calendar_page.dart';

// =============================================================================
// ALGORITMO NAP
// =============================================================================
class NapAlgorithm {
  final List<MyEvent> todayEvents;
  final TimeOfDay? wakeUpToday;
  final TimeOfDay? averageSchoolWakeUp;
  final DateTime today;
  // SDS reale proveniente dal wearable; se null si usa il valore debug
  final double? sdsOverride;

  NapAlgorithm({
    required this.todayEvents,
    required this.wakeUpToday,
    required this.averageSchoolWakeUp,
    required this.today,
    this.sdsOverride,
  });

  List<(int, int)> _buildGaps(int from, int to) {
    if (from >= to) return [];

    final intervals =
        todayEvents
            .where((e) => e.category != 'Pranzo')
            .map((e) => (toMin(e.startTime), toMin(e.endTime)))
            .toList()
          ..sort((a, b) => a.$1.compareTo(b.$1));

    final merged = <(int, int)>[];

    for (final iv in intervals) {
      if (merged.isEmpty || iv.$1 >= merged.last.$2) {
        merged.add(iv);
      } else {
        final maxEnd = iv.$2 > merged.last.$2 ? iv.$2 : merged.last.$2;
        merged[merged.length - 1] = (merged.last.$1, maxEnd);
      }
    }

    final gaps = <(int, int)>[];
    int cursor = from;

    for (final iv in merged) {
      if (iv.$1 > cursor) {
        final gStart = cursor;
        final gEnd = iv.$1 < to ? iv.$1 : to;
        if (gStart < gEnd) gaps.add((gStart, gEnd));
      }
      if (iv.$2 > cursor) cursor = iv.$2;
    }

    if (cursor < to) gaps.add((cursor, to));

    return gaps;
  }

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
  // Se sdsOverride è fornito (dati reali dal wearable) lo usa direttamente.
  // Altrimenti usa il valore fisso di debug.
  static const double _sdsDebug = 0;

  double computeSDS() => sdsOverride ?? _sdsDebug;

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
  // Invariante garantita in tutti i rami:
  //   greenStart ≤ greenEnd ≤ yellowEnd ≤ orangeEnd
  // Nel ramo feriale/domenica con sveglia, yellowEnd e orangeEnd dipendono
  // solo dalla sveglia (mai dal pranzo, mai da un tetto fisso sull'orologio
  // — vedi sotto per il perché). Se il pranzo è tardivo, collassano invece
  // greenStart/greenEnd (ed eventualmente anche yellowEnd, se il pranzo
  // supera pure quello).
  ZoneLimits computeZoneLimits() {
    final zoneStart = _zoneStartMin();

    // Helper: se il pranzo finisce tardi e zoneStart supera orangeEnd → zona rossa
    ZoneLimits allRed(int orangeEnd) => ZoneLimits(
      greenStart: orangeEnd,
      greenEnd:   orangeEnd,
      yellowEnd:  orangeEnd,
      orangeEnd:  orangeEnd,
    );

    // ---- SABATO: valori fissi ----
    if (_isSaturday) {
      const satOrangeEnd = 19 * 60; // 18:00 fisso
      if (zoneStart >= satOrangeEnd) return allRed(satOrangeEnd);
      final greenEnd  = zoneStart > hm(15, 30) ? zoneStart : hm(15, 30);
      final yellowEnd = greenEnd  > hm(17, 30) ? greenEnd  : hm(17, 30);
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd:   greenEnd,
        yellowEnd:  yellowEnd,
        orangeEnd:  satOrangeEnd,
      );
    }

    // ---- FALLBACK senza dati sveglia ----
    if (_effectiveWakeUp == null) {
      const fixedYellowEnd = 16 * 60; // 16:00
      // orangeEnd = yellowEnd + 90min, max 18:00
      final orangeEnd = (fixedYellowEnd + 90).clamp(fixedYellowEnd, hm(19, 0));
      if (zoneStart >= orangeEnd) return allRed(orangeEnd);
      // greenEnd e yellowEnd non possono scendere sotto zoneStart
      final greenEnd  = zoneStart > hm(15, 0)      ? zoneStart      : hm(15, 0);
      final yellowEnd = greenEnd  > fixedYellowEnd  ? greenEnd       : fixedYellowEnd;
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd:   greenEnd,
        yellowEnd:  yellowEnd,
        orangeEnd:  orangeEnd,
      );
    }

    // ---- GIORNI FERIALI / DOMENICA con sveglia ----
    final wakeUp = _isSunday
        ? (averageSchoolWakeUp ?? _effectiveWakeUp!)
        : _effectiveWakeUp!;

    final wakeUpMin = toMin(wakeUp);
    final hasPranzo = todayEvents.any((e) => e.category == 'Pranzo');

    // yellowEnd/orangeEnd dipendono SOLO dalla sveglia, MAI dal pranzo
    // (il pranzo può solo far collassare verde/gialla, mai spingerli
    // avanti — vedi sotto). Niente più tetto fisso sull'orologio: la
    // formula "ore dopo la sveglia" rappresenta già correttamente la
    // distanza dal bedtime (bedtime ≈ sveglia + 16h, quindi wake+9h =
    // bedtime-7h), qualunque sia l'orario della sveglia stessa. Un tetto
    // fisso avrebbe senso solo se esistesse un limite biologico assoluto
    // indipendente dal proprio ritmo — che non risulta esserci.
    final yellowEnd = wakeUpMin + 9 * 60;
    final orangeEnd = yellowEnd + 90;

    // greenEnd "naturale": 8h dopo la sveglia, mai oltre yellowEnd.
    final rawGreenEnd = wakeUpMin + 8 * 60;
    final greenEndNatural = rawGreenEnd < yellowEnd ? rawGreenEnd : yellowEnd;

    // Quanto serve almeno per un pisolino (10 latenza + 10 pisolino minimo,
    // il gradino più basso di napSteps), per il controllo di zona rossa.
    final minSlotNeeded = 10 + napSteps.last;

    if (hasPranzo) {
      // zoneStart = fine pranzo + 40min (da _zoneStartMin()).

      // Zona rossa: non c'è nemmeno spazio per il pisolino minimo prima
      // di orangeEnd (basato solo sulla sveglia, il pranzo non lo tocca).
      if (zoneStart + minSlotNeeded > orangeEnd) return allRed(orangeEnd);

      if (zoneStart >= yellowEnd) {
        // Il pranzo supera anche la fine della zona gialla: verde e
        // gialla collassano insieme a zoneStart. orangeEnd resta quello
        // basato sulla sveglia — il pranzo non lo estende mai.
        return ZoneLimits(
          greenStart: zoneStart,
          greenEnd:   zoneStart,
          yellowEnd:  zoneStart,
          orangeEnd:  orangeEnd,
        );
      }

      // Il pranzo lascia la gialla intatta: collassa solo il verde se serve.
      final greenEnd = zoneStart > greenEndNatural ? zoneStart : greenEndNatural;
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd:   greenEnd,
        yellowEnd:  yellowEnd,
        orangeEnd:  orangeEnd,
      );
    }

    // ---- Nessun pranzo: zoneStart effettivo basato sulla sveglia reale
    // (minimo tra wakeup+7h e le 13:30) invece del valore fisso 14:00 di
    // _zoneStartMin(), così l'inizio si allinea anche a sveglie presto.
    final rawEffectiveStart = wakeUpMin + 7 * 60;
    final effectiveZoneStart =
        rawEffectiveStart < hm(13, 30) ? rawEffectiveStart : hm(13, 30);

    if (effectiveZoneStart + minSlotNeeded > orangeEnd) {
      return allRed(orangeEnd);
    }

    final greenEnd =
        effectiveZoneStart > greenEndNatural ? effectiveZoneStart : greenEndNatural;
    final greenStart =
        (greenEnd - 60) < hm(13, 30) ? (greenEnd - 60) : hm(13, 30);

    return ZoneLimits(
      greenStart: greenStart,
      greenEnd:   greenEnd,
      yellowEnd:  yellowEnd,
      orangeEnd:  orangeEnd,
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
    if (n <= 30) return 70;
    return 100;
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
    final now = TimeOfDay.now();
    final nowMin = toMin(now);

    if (nowMin >= lim.orangeEnd) return _noNap();

    final baseStart = nowMin > lim.greenStart ? nowMin : lim.greenStart;
    int stepIdx = napSteps.indexWhere((s) => s <= _idealDuration(sds));
    if (stepIdx == -1) stepIdx = napSteps.length - 1;

    // --- Ciclo principale: scala napMin fino a trovare uno slot ---
    while (stepIdx < napSteps.length) {
      final napMin = napSteps[stepIdx];
      final cogn = _inerziaCogn(napMin);
      final motor = _inerziaMotor(napMin);
      final needed = 10 + napMin;

      // Buchi disponibili da ora fino a fine zona gialla
      // (il pisolino deve TERMINARE entro yellowEnd)
      final gaps = _buildGaps(baseStart, lim.yellowEnd);
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
    final orangeNeeded = 10 + orangeNap;
    // Inizia la ricerca arancione 19 min prima della fine zona gialla
    // (latenza 10 + pisolino minimo 10 - 1 di margine = 19).
    // Così non si perde nessuna finestra utile tra la fine dello spazio
    // disponibile in giallo e l'inizio "ufficiale" della zona arancione.
    final orangeEarlyStart = lim.yellowEnd - 19;
    final orangeFrom = baseStart > orangeEarlyStart
        ? baseStart
        : orangeEarlyStart;

    // Buchi liberi dentro la zona arancione
    final orangeGaps = _buildGaps(orangeFrom, lim.orangeEnd);

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
