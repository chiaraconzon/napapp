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

  NapAlgorithm({
    required this.todayEvents,
    required this.wakeUpToday,
    required this.averageSchoolWakeUp,
    required this.today,
  });

  static const latencyMin=10;

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
  // Valore fisso temporaneo in attesa dell'integrazione con il wearable.
  // 0.0 = nessun debito (propone pisolino da 15 min)
  // 1.5 = debito moderato (propone pisolino da 90 min)
  static const double _sdsDebug = 0.0;

  double computeSDS() => _sdsDebug;

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
  //   zoneStart ≤ greenEnd ≤ yellowEnd ≤ orangeEnd ≤ 19:00
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
      const satOrangeEnd = 18 * 60; // 18:00 fisso
      if (zoneStart >= satOrangeEnd) return allRed(satOrangeEnd);
      final greenEnd  = zoneStart > hm(15, 30) ? zoneStart : hm(15, 30);
      final yellowEnd = greenEnd  > hm(17, 00) ? greenEnd  : hm(17, 00);
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
      // orangeEnd = yellowEnd + 90min, max 19:00
      final orangeEnd = 18 * 60;
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

    // greenEnd: equivalente a 8h prima del bedtime -> 8h DOPO la sveglia
    int rawGreenEnd = wakeUpMin + 8 * 60;

    // yellowEnd: equivalente a 7h prima del bedtime -> 9h DOPO la sveglia
    int rawYellowEnd = wakeUpMin + 9 * 60;
    
    // yellowEnd: cappato a 17:30
    final yellowEnd = rawYellowEnd.clamp(zoneStart, hm(17, 30));
    
    // greenEnd: non può superare yellowEnd
    final greenEnd  = rawGreenEnd.clamp(zoneStart, yellowEnd);
    
    // orangeEnd: yellowEnd + 90min, max 19:00
    final orangeEnd = (yellowEnd + 90).clamp(yellowEnd, hm(18, 0));
    if (zoneStart >= orangeEnd) return allRed(orangeEnd);

    // Se non c'è pranzo → greenStart = greenEnd - 60min (1h prima della fine verde)
    // Se c'è pranzo    → greenStart = fine pranzo + 40min (= zoneStart)
    final hasPranzo = todayEvents.any((e) => e.category == 'Pranzo');
    // Calcoliamo il minimo tra (greenEnd - 60) e le 14:00
    final greenStartNoPranzo = (greenEnd - 60) < hm(13, 30) ? (greenEnd - 60) : hm(13, 30);
    final greenStart = hasPranzo ? zoneStart : greenStartNoPranzo;

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
    if (n <= 25) return 40;
    if (n <= 30) return 50;
    if (n <= 75) return 80;
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
      final needed = latencyMin + napMin;

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
    final orangeNeeded = latencyMin + orangeNap;
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
