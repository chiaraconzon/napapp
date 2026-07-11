import 'package:flutter/material.dart';
import 'package:napapp/models/sleep.dart';

class WeeklyInsightCard extends StatelessWidget {
  final List<SleepData> sleepData2weeks;

  const WeeklyInsightCard({super.key, required this.sleepData2weeks});

  int avgChange(List<SleepData> sleepData2weeks) {
    int sumThisWeek = 0;
    int countThisWeek = 0;

    int sumLastWeek = 0;
    int countLastWeek = 0;

    for (int i = 0; i < 7; i++) {
      int? mins = sleepData2weeks[i].minutesAsleep;
      if (mins != null) {
        sumLastWeek += mins;
        countLastWeek += 1;
      }
    }

    for (int i = 7; i < 13; i++) {
      int? mins = sleepData2weeks[i].minutesAsleep;
      if (mins != null) {
        sumThisWeek += mins;
        countThisWeek += 1;
      }
    }

    double avgLastWeek = sumLastWeek / countLastWeek;
    double avgThisWeek = sumThisWeek / countThisWeek;

    return (avgThisWeek - avgLastWeek).round();
  }

  @override
  Widget build(BuildContext context) {
    int avgMinChange = avgChange(sleepData2weeks);
    final theme = Theme.of(context);

    String changeMsg = "";
    String howChange = "";
    Icon trendIcon;

    if (avgMinChange > 0) {
      changeMsg = "Your sleep consistency improved this week!";
      howChange = "+$avgMinChange min average sleep";
      trendIcon = Icon(
        Icons.trending_up_rounded,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    } else if (avgMinChange < 0) {
      changeMsg = "Your sleep consistency decreased this week.";
      howChange = "-${avgMinChange * (-1)} min average sleep";
      trendIcon = Icon(
        Icons.trending_down_rounded,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    } else {
      changeMsg = "Your sleep consistency did not change this week.";
      howChange = "No change in average sleep";
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
                  "Weekly Insight",

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
