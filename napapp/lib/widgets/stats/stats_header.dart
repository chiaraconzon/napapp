import 'package:flutter/material.dart';
import '../../screens/app_strings.dart';

// Header of the stats page
class StatsHeader extends StatelessWidget {
  final bool isEnglish;

  const StatsHeader({super.key, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings(isEnglish);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.statsHeaderTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          s.statsHeaderSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
