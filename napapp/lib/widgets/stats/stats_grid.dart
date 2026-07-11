import 'package:flutter/material.dart';
import 'stats_card.dart';
import 'package:napapp/models/sleep.dart';

class StatsGrid extends StatelessWidget {
  final List<SleepData> sleepData;
  final int nNaps = 2; // mock value, could be improved upon further development

  const StatsGrid({super.key, required this.sleepData});

  // Computes average minutes of sleep of the past 7 days
  int avgSleepMin(List<SleepData> sleepData) {
    int sumThisWeek = 0;
    int countThisWeek = 0;

    for (int i = 0; i < 7; i++) {
      int? mins = sleepData[i].minutesAsleep;
      if (mins != null) {
        sumThisWeek += mins;
        countThisWeek += 1;
      }
    }
    int avgSleep = (sumThisWeek / countThisWeek).round();

    return avgSleep;
  }
  
  // Computes string that displays the average in hours and minutes
  String avgSleepMsg(List<SleepData> sleepData) {
    int avgSleep = avgSleepMin(sleepData);

    int hrs = (avgSleep / 60).floor();
    int min = avgSleep % 60;

    return "$hrs h $min m";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 14,
      mainAxisSpacing: 14,

      childAspectRatio: 1.35,

      children: [
        // Displays the sleep average of the past 7 days
        StatCard(
          icon: Icons.nightlight_round,
          title: "Average Sleep (last 7 days)",
          value: avgSleepMsg(sleepData),
          accentColor: colors.tertiary,
        ),
        // Displays number of naps of the week (mock value: point of possible future developments)
        StatCard(
          icon: Icons.calendar_month_rounded,
          title: "This Week",
          value: "$nNaps naps",
          accentColor: colors.secondary,
        ),
      ],
    );
  }
}
