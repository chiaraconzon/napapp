import 'package:flutter/material.dart';
import '../models/nap_models.dart';
import '../utils/time_utils.dart';
import '../screens/app_strings.dart';

class PredictionBox extends StatelessWidget {
  final NapResult? r;
  final bool isEnglish;

  const PredictionBox({super.key, required this.r, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish);
    final result = r;

    if (result == null ||
        result.zone == NapZone.red ||
        result.napEffectiveMin == 0) {
      return _redBox(context, s);
    }

    if (result.zone == NapZone.orange) {
      return _orangeBox(context, s);
    }

    return _greenYellowBox(context, s, result);
  }

  // ------------------------------------------------------------------
  Widget _redBox(BuildContext context, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
  Widget _orangeBox(BuildContext context, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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

  // ------------------------------------------------------------------
  Widget _greenYellowBox(BuildContext context, AppStrings s, NapResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isGreen = result.zone == NapZone.green;
    final color = isGreen ? Colors.green : Colors.amber;

    final label = isGreen ? s.idealNap : s.emergencyNapPrediction;
    final start = TimeUtils.fmtTOD(result.suggestedStart!);

    final bg = isDark ? color.withOpacity(0.15) : color.withOpacity(0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            TextSpan(
              text: '${result.totalDisplayMin} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '  •  '),
            TextSpan(
              text: '${result.scopeEmoji} ${s.translateScope(result.scope)}',
            ),
            TextSpan(text: '  •  ${s.fromTime} '),
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
