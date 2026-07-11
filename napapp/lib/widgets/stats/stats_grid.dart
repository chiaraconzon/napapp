import 'package:flutter/material.dart';
import 'stats_card.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

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
        StatCard(
          icon: Icons.nightlight_round,
          title: "Average Sleep",
          value: "7h 42m",
          accentColor: colors.tertiary,
        ),

        StatCard(
          icon: Icons.bedtime_rounded,
          title: "Average Nap",
          value: "24 min",
          accentColor: colors.secondary,
        ),

        StatCard(
          icon: Icons.bolt_rounded,
          title: "Recovery",
          value: "86%",
          accentColor: Colors.green,
        ),

        StatCard(
          icon: Icons.calendar_month_rounded,
          title: "This Week",
          value: "5 naps",
          accentColor: colors.secondary,
        ),
      ],
    );
  }
}
