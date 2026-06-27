import '../algorithms/nap_algorithm.dart';
import '../models/nap_models.dart';
import '../screens/calendar_page.dart';
import 'package:flutter/material.dart';

class NapController {
  final double sleepTarget;
  final int latencyMin;
  final List<SleepDay> sleepHistory;
  final Map<DateTime, List<MyEvent>> globalEvents;
  final TimeOfDay defaultWakeUp;

  NapResult? napResult;
  ZoneLimits? zoneLimits;
  double sds = 0.0;

  NapController({
    required this.sleepTarget,
    required this.latencyMin,
    required this.sleepHistory,
    required this.globalEvents,
    required this.defaultWakeUp,
  });

  void refresh(DateTime now) {
    final key = DateTime(now.year, now.month, now.day);

    final algo = NapAlgorithm(
      sleepTarget: sleepTarget,
      latencyMin: latencyMin,
      sleepHistory: sleepHistory,
      todayEvents: globalEvents[key] ?? [],
      wakeUpToday: null,
      averageSchoolWakeUp: defaultWakeUp,
      today: now,
    );

    napResult = algo.compute();
    zoneLimits = algo.computeZoneLimits();
    sds = algo.computeSDS();
  }
}
