import 'package:flutter/material.dart';

class SleepScoreCard extends StatelessWidget {
  final int score;

  const SleepScoreCard({super.key, this.score = 91});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String message;

    if (score >= 90) {
      message = "Excellent sleep";
    } else if (score >= 70) {
      message = "Good sleep";
    } else {
      message = "Needs attention";
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
            "Sleep Score",
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
                // Cerchio di sfondo
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

                // Cerchio progresso
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

                // Score centrale
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
