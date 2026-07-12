import 'package:flutter/material.dart';
import 'package:napapp/models/sleep.dart';
import '../../screens/app_strings.dart';

class WeeklyInsightCard extends StatelessWidget {
  final List<SleepData> sleepData2weeks;
  final bool isEnglish;

  const WeeklyInsightCard({
    super.key,
    required this.sleepData2weeks,
    this.isEnglish = false,
  });

  // Computes change in average minutes of sleep of the current and past week (current week is defined as the most recent 7 days)
  int avgChange(List<SleepData> sleepData2weeks) {
    int sumThisWeek = 0;
    int countThisWeek = 0;

    int sumLastWeek = 0;
    int countLastWeek = 0;
    // Computes sum of minutes of sleep and number of days available in the LAST week
    // LAST because the list of sleepData is ordered chronologically
    for (int i = 0; i < 7; i++) {
      int? mins = sleepData2weeks[i].minutesAsleep;
      if (mins != null) {
        sumLastWeek += mins;
        countLastWeek += 1;
      }
    }

    // Computes sum of minutes of sleep and number of days available in the RECENT week
    for (int i = 7; i < 13; i++) {
      int? mins = sleepData2weeks[i].minutesAsleep;
      if (mins != null) {
        sumThisWeek += mins;
        countThisWeek += 1;
      }
    }
    
    // Compute averages
    double avgLastWeek = sumLastWeek / countLastWeek;
    double avgThisWeek = sumThisWeek / countThisWeek;

    // Computes change and rounds to int
    return (avgThisWeek - avgLastWeek).round();
  }

  @override
  Widget build(BuildContext context) {
    int avgMinChange = avgChange(sleepData2weeks);
    final theme = Theme.of(context);
    final s = AppStrings(isEnglish);

    String changeMsg = "";
    String howChange = "";
    Icon trendIcon;

    // Messages and icon of the widget changing depending on if the change is positive, negative or 0
    if (avgMinChange > 0) {
      changeMsg = s.sleepImprovedMsg;
      howChange = s.avgSleepIncrease(avgMinChange);
      trendIcon = Icon(
        Icons.trending_up_rounded,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    } else if (avgMinChange < 0) {
      changeMsg = s.sleepDecreasedMsg;
      howChange = s.avgSleepDecrease(avgMinChange * (-1));
      trendIcon = Icon(
        Icons.trending_down_rounded,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    } else {
      changeMsg = s.sleepUnchangedMsg;
      howChange = s.avgSleepNoChange;
      trendIcon = Icon(
        Icons.trending_neutral_rounded,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 42,

            width: 42,

            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.lightbulb_rounded,

              color: theme.colorScheme.onSecondary,

              size: 23,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  s.weeklyInsightTitle,

                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(changeMsg, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 12),

                Row(
                  children: [
                    trendIcon,

                    const SizedBox(width: 6),

                    Text(
                      howChange,

                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,

                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
