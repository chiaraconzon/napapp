import 'package:flutter/material.dart';
import '../models/nap_models.dart';
import '../screens/calendar_page.dart';

//NAP ALGORITHM
class NapAlgorithm {
  final List<MyEvent> todayEvents;
  final TimeOfDay? wakeUpToday;
  final TimeOfDay? averageSchoolWakeUp;
  final DateTime today;
  // Real SDS (Sleep Debt Score) from wearable; falls back to debug value if null
  final double? sdsOverride;

  NapAlgorithm({
    required this.todayEvents,
    required this.wakeUpToday,
    required this.averageSchoolWakeUp,
    required this.today,
    this.sdsOverride,
  });

  // Finds free time slots (gaps) by extracting and merging overlapping non-lunch events. 
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

  // Helpers for time conversions (Hours/Minutes to total minutes and vice versa) 
  static int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  static int hm(int h, int m) => h * 60 + m;
  static TimeOfDay fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
  static String fmtMin(int m) {
    final h = (m ~/ 60) % 24;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  //  SDS (Sleep Debt Score) Management
  static const double _sdsDebug = 0;
  double computeSDS() => sdsOverride ?? _sdsDebug;

  // Effective wakeup
  TimeOfDay? get _effectiveWakeUp => wakeUpToday ?? averageSchoolWakeUp;

  // day type
  bool get _isSaturday => today.weekday == DateTime.saturday;
  bool get _isSunday => today.weekday == DateTime.sunday;

  // Determines the earliest possible time for a nap (40 mins after lunch, or 14:00 default)
  int _zoneStartMin() {
    final pranzi = todayEvents.where((e) => e.category == 'Pranzo').toList();
    if (pranzi.isNotEmpty) {
      pranzi.sort((a, b) => toMin(a.startTime).compareTo(toMin(b.startTime)));
      return toMin(pranzi.first.endTime) + 40;
    }
    return hm(14, 0);
  }

  // Calculates the boundaries for Green, Yellow, Orange, and Red zones based on wake-up time and day type.
  ZoneLimits computeZoneLimits() {
    final zoneStart = _zoneStartMin();

    // Helper: Locks all zones to Red if the nap window is missed (too late).
    ZoneLimits allRed(int orangeEnd) => ZoneLimits(
      greenStart: orangeEnd,
      greenEnd: orangeEnd,
      yellowEnd: orangeEnd,
      orangeEnd: orangeEnd,
    );

    // SATURDAY: Uses fixed optimal hours 
    if (_isSaturday) {
      const satOrangeEnd = 19 * 60; // 19:00 fixed
      if (zoneStart >= satOrangeEnd) return allRed(satOrangeEnd);
      final greenEnd = zoneStart > hm(17, 00) ? zoneStart : hm(17, 00);
      final yellowEnd = greenEnd > hm(18, 00) ? greenEnd : hm(18, 00);
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd: greenEnd,
        yellowEnd: yellowEnd,
        orangeEnd: satOrangeEnd,
      );
    }

    // FALLBACK (No wake-up data): Uses hardcoded estimates (Green until 15:00, Yellow until 16:00).
    if (_effectiveWakeUp == null) {
      const fixedYellowEnd = 16 * 60; // 16:00
      final orangeEnd = fixedYellowEnd + 90; //17:30
      if (zoneStart >= orangeEnd) return allRed(orangeEnd);
      final greenEnd = zoneStart > hm(15, 0) ? zoneStart : hm(15, 0);
      final yellowEnd = greenEnd > fixedYellowEnd ? greenEnd : fixedYellowEnd;
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd: greenEnd,
        yellowEnd: yellowEnd,
        orangeEnd: orangeEnd,
      );
    }

    // WEEKDAYS / SUNDAYS (With wake-up data): Dynamic limits based on biological clock.
    final wakeUp = _isSunday
        ? (averageSchoolWakeUp ?? _effectiveWakeUp!) //if is sunday take the average if it is possible
        : _effectiveWakeUp!;

    final wakeUpMin = toMin(wakeUp);
    final hasPranzo = todayEvents.any((e) => e.category == 'Pranzo');

    final yellowEnd = wakeUpMin + 9 * 60; // 9 hours after waking up (7 before going to bed)
    final orangeEnd = yellowEnd + 90; //9h + 1h
    final rawGreenEnd = wakeUpMin + 8 * 60; // 8 hours after waking up
    final greenEndNatural = rawGreenEnd < yellowEnd ? rawGreenEnd : yellowEnd;
    
    final minSlotNeeded = 10 + napSteps.last; //min nap (10min + 10min latency)

    if (hasPranzo) {
      // zoneStart = end lunch + 40min.

      // If lunch pushes the schedule too late, return Red Zone.
      if (zoneStart + minSlotNeeded > orangeEnd) return allRed(orangeEnd);

      // If lunch pushes past Yellow, collapse Green/Yellow zones.
      if (zoneStart >= yellowEnd) {
        return ZoneLimits(
          greenStart: zoneStart,
          greenEnd: zoneStart,
          yellowEnd: zoneStart,
          orangeEnd: orangeEnd,
        );
      }

      final greenEnd = zoneStart > greenEndNatural
          ? zoneStart
          : greenEndNatural;
      return ZoneLimits(
        greenStart: zoneStart,
        greenEnd: greenEnd,
        yellowEnd: yellowEnd,
        orangeEnd: orangeEnd,
      );
    }

    // No lunch events recorded (min between wakeup+7h and 14:00).
    final rawEffectiveStart = wakeUpMin + 7 * 60;
    final effectiveZoneStart = rawEffectiveStart < hm(14, 00)
        ? rawEffectiveStart
        : hm(14, 00);

    if (effectiveZoneStart + minSlotNeeded > orangeEnd) {
      return allRed(orangeEnd);
    }

    final greenEnd = effectiveZoneStart > greenEndNatural
        ? effectiveZoneStart
        : greenEndNatural;
    final greenStart = (greenEnd - 60) < hm(14, 00)
        ? (greenEnd - 60)
        : hm(14, 00);

    return ZoneLimits(
      greenStart: greenStart,
      greenEnd: greenEnd,
      yellowEnd: yellowEnd,
      orangeEnd: orangeEnd,
    );
  }

  // map a time offset to its corresponding zone color.
  NapZone _zoneOfOffset(int offsetMin, ZoneLimits lim) {
    if (offsetMin <= lim.greenEnd) return NapZone.green;
    if (offsetMin <= lim.yellowEnd) return NapZone.yellow;
    if (offsetMin <= lim.orangeEnd) return NapZone.orange;
    return NapZone.red;
  }

  // Allowed nap durations in descending order.
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

  // Determines the ideal nap length based on Sleep Debt and upcoming study/lesson events.
  int _idealDuration(double sds) {
    if (sds > 1.0) return 90;
    final hasStudy = todayEvents.any(
      (e) => e.category == 'Studio' || e.category == 'Lezione',
    );
    if (hasStudy) return 30;
    return 15;
  }

  // Sleep Inertia: Calculates required buffer time after waking up before cognitive/motor activities.
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

  // Nap Labels based on nap duration
  String _scopeLabel(int n) {
    if (n >= 60) return 'Energie';
    if (n >= 20) return 'Focus';
    return 'Riflessi';
  }

  String _scopeEmoji(int n) {
    if (n >= 60) return '🔋';
    if (n >= 20) return '🧠';
    return '⚡';
  }

  // MAIN ENGINE: Finds the optimal nap slot checking zones, events, and inertia.
  NapResult compute() {
    final sds = computeSDS();
    final lim = computeZoneLimits();
    final now = TimeOfDay.now();
    final nowMin = toMin(now);

    // Too late to nap.
    if (nowMin >= lim.orangeEnd) return _noNap();

    final baseStart = nowMin > lim.greenStart ? nowMin : lim.greenStart;

    // Find the starting point in the allowed durations array.
    int stepIdx = napSteps.indexWhere((s) => s <= _idealDuration(sds));
    if (stepIdx == -1) stepIdx = napSteps.length - 1;

    // Search Loop: Try to fit the largest possible valid nap in the available gaps
    while (stepIdx < napSteps.length) {
      final napMin = napSteps[stepIdx];
      final cogn = _inerziaCogn(napMin);
      final motor = _inerziaMotor(napMin);
      final needed = 10 + napMin; // Includes 10 min fall-asleep latency

      // Find gaps before the Yellow Zone ends
      final gaps = _buildGaps(baseStart, lim.yellowEnd);
      
      for (final gap in gaps) {
        final napStart = gap.$1;
        final napEnd = napStart + needed;

        // Skip if nap doesn't fit in the gap or exceeds Yellow Zone. 
        if (napEnd > gap.$2) continue;
        if (napEnd > lim.yellowEnd) continue;

        // Check Sleep Inertia against upcoming events
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

        // Perfect match.
        if (cognOk && motorOk) {
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

        // Acceptable mismatch: Long nap with a slight cognitive inertia violation (triggers warning UI).
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

        // not valid gap, go to the next one
      }

      // Decrease nap duration and try again if no gap fits.
      stepIdx++;
    }

    // Fallback orange zone: 10 min + latenza (fixed) → inerzia_cogn(10) = 0, inerzia_motor(10) = 30 min
    const orangeNap = 10;
    const orangeMotor = 30; // _inerziaMotor(10)
    final orangeNeeded = 10 + orangeNap;
    
    // Start scanning just before Yellow ends to catch overlapping edge cases (19min before the yellow end).
    final orangeEarlyStart = lim.yellowEnd - 19;
    final orangeFrom = baseStart > orangeEarlyStart
        ? baseStart
        : orangeEarlyStart;

    // gaps in the orange zone
    final orangeGaps = _buildGaps(orangeFrom, lim.orangeEnd);

    for (final gap in orangeGaps) {
      final napStart = gap.$1;
      final napEnd = napStart + orangeNeeded;

      // Can't be out of the gap or the orange zone
      if (napEnd > gap.$2) continue;
      if (napEnd > lim.orangeEnd) continue;

      // Motor inertia check for the quick power nap (30 min of motor inertia).
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

      // Valid fallback slot found.
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

    // No nap fits at all
    return _noNap();
  }

  NapResult _noNap() => NapResult(
    zone: NapZone.red,
    napEffectiveMin: 0,
    totalDisplayMin: 0,
    scope: '',
    scopeEmoji: '',
  );
}
