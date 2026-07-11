import 'package:flutter/material.dart';

class WeeklyInsightCard extends StatelessWidget {
  const WeeklyInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                Text(
                  "Your sleep consistency improved this week.",

                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,

                      size: 18,

                      color: theme.colorScheme.tertiary,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "+32 min average sleep",

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
