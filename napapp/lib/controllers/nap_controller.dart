import '../algorithms/nap_algorithm.dart';
import '../models/nap_models.dart';
import '../screens/calendar_page.dart';

class NapController {
  final double sleepTarget;
  final int latencyMin;
  final List<SleepDay> sleepHistory;
  final Map<DateTime, List<MyEvent>> globalEvents;

  NapResult? napResult;
  ZoneLimits? zoneLimits;
  double sds = 0.0;

  NapController({
    required this.sleepTarget,
    required this.latencyMin,
    required this.sleepHistory,
    required this.globalEvents,
  });

  void refresh(DateTime now) {
    final key = DateTime(now.year, now.month, now.day);

    final algo = NapAlgorithm(
      sleepTarget: sleepTarget,
      latencyMin: latencyMin,
      sleepHistory: sleepHistory,
      todayEvents: globalEvents[key] ?? [],
      wakeUpToday: null, // TODO: collegare al wearable
      averageSchoolWakeUp: null, // null → usa fallback fissi 14:00/15:00/16:00
      today: now,
    );

    napResult = algo.compute();
    zoneLimits = algo.computeZoneLimits();
    sds = algo.computeSDS();
  }
}
