import 'package:flutter/material.dart';
import '../../models/nap_models.dart';
import '../../utils/time_utils.dart';
import '../../screens/app_strings.dart';

// Widget that displays the recommended nap prediction message
class PredictionBox extends StatelessWidget {
  final NapResult? r;
  final bool isEnglish;

  const PredictionBox({super.key, required this.r, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish); //english-italiano
    final result = r;

    // Show red message when no nap is recommended
    if (result == null ||
        result.zone == NapZone.red ||
        result.napEffectiveMin == 0) {
      return _redBox(context, s);
    }

    // Show orange message for emergency nap window
    if (result.zone == NapZone.orange) {
      return _orangeBox(context, s);
    }

    // Show recommended nap information for green/yellow zones
    return _greenYellowBox(context, s, result);
  }

  // ------------------------------------------------------------------
  // Builds the warning box when a nap is not recommended
  Widget _redBox(BuildContext context, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // Red warning style adapted to current theme
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.errorContainer
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Theme.of(context).colorScheme.error.withOpacity(0.4)
              : Colors.red.shade200,
        ),
      ),
      child: Row(
        // Displays icon and warning message
        children: [
          Icon(
            Icons.block,
            size: 20,
            color: isDark ? Theme.of(context).colorScheme.error : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.redZoneMsg,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: isDark
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Builds the message box for emergency nap periods
  Widget _orangeBox(BuildContext context, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // Orange warning style
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.15) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Text(
        s.orangeMsg,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Theme.of(context).colorScheme.onSurface
              : Colors.orange.shade800,
        ),
      ),
    );
  }

  // // Builds the main prediction box for valid nap recommendations
  Widget _greenYellowBox(BuildContext context, AppStrings s, NapResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Select color and label based on nap quality zone
    final isGreen = result.zone == NapZone.green;
    final color = isGreen ? Colors.green : Colors.amber;
    final label = isGreen ? s.idealNap : s.emergencyNapPrediction;
    // Format recommended starting time
    final start = TimeUtils.fmtTOD(result.suggestedStart!);

    final bg = isDark ? color.withOpacity(0.15) : color.withOpacity(0.08);

    return Container(
      // Background and border follow nap zone color
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      // Displays formatted nap recommendation information
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            // Nap category label
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            // Recommended duration
            TextSpan(
              text: '${result.totalDisplayMin} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '  •  '),
            // Nap purpose/scope
            TextSpan(
              text: '${result.scopeEmoji} ${s.translateScope(result.scope)}',
            ),
            TextSpan(text: '  •  ${s.fromTime} '),
            // Recommended starting time
            TextSpan(
              text: start,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
