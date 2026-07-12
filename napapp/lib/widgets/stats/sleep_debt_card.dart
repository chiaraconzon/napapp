import 'package:flutter/material.dart';
import '../../screens/app_strings.dart';

class SleepDebtCard extends StatelessWidget {
  // Value of the sleep debt computed by the algorithm
  final double sds;
  final bool isEnglish;

  const SleepDebtCard({super.key, required this.sds, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings(isEnglish);

    String message;

    // Message depends on the value of the sleep debt
    if (sds < 1) {
      message = s.wellRestedMsg;
    } else {
      message = s.recoveryNeededMsg;
    }

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,

        borderRadius: BorderRadius.circular(28),

        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            s.sleepDebtTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "${sds.toStringAsFixed(2)} h",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Icon(
                Icons.battery_charging_full_rounded,
                size: 38,
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: sds,

              minHeight: 12,

              backgroundColor: theme.colorScheme.surfaceContainerHighest,

              color: theme.colorScheme.secondary,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
