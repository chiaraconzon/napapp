import 'package:flutter/material.dart';
import '../../screens/app_strings.dart';

// Widget that displays sleep debt status with a visual indicator
class SdsReward extends StatelessWidget {
  final double sds;
  final bool isEnglish; 

  const SdsReward({super.key, required this.sds, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish); //italiano-english

    // Variables used to define the reward appearance
    late String emoji, label;
    late Color color;

    // Assigns message and color according to sleep debt severity
    if (sds < 0.5) {
      emoji = '🔋';
      label = s.sdsGreat;
      color = Colors.green;
    } else if (sds < 1.0) {
      emoji = '🙂';
      label = s.sdsLight;
      color = Colors.lightGreen;
    } else if (sds < 2.0) {
      emoji = '🥱';
      label = s.sdsModerate;
      color = Colors.orange.shade800;
    } else {
      emoji = '🚨';
      label = s.sdsSevere;
      color = Colors.red;
    }

    // Creates a box showing sleep debt condition
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // Background and border use the status color
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status emoji
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          // Status description
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
