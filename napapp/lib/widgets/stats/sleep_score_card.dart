import 'package:flutter/material.dart';
import '../../screens/app_strings.dart';

class SleepScoreCard extends StatelessWidget {
  final int score;
  final bool isEnglish;

  const SleepScoreCard({super.key, this.score = 91, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings(isEnglish);

    String message;

    if (score >= 90) {
      message = s.excellentSleepMsg;
    } else if (score >= 70) {
      message = s.goodSleepMsg;
    } else {
      message = s.needsAttentionMsg;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),

      child: Column(
        children: [
          Text(
            s.sleepScoreTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 130,
            width: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  height: 130,
                  width: 130,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),

                // Progress circle
                SizedBox(
                  height: 130,
                  width: 130,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    color: theme.colorScheme.secondary,
                  ),
                ),

                // Central score
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$score",
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),

                    Text(
                      "/100",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
