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
      return _redBox(s);
    }

    if (result.zone == NapZone.orange) {
      return _orangeBox(s);
    }

    return _greenYellowBox(s, result);
  }

  Widget _redBox(AppStrings s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.block, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 10),
          Text(
            s.redZoneMsg,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orangeBox(AppStrings s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(
        s.orangeMsg,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }

  Widget _greenYellowBox(AppStrings s, NapResult result) {
    final isGreen = r!.zone == NapZone.green;
    final color = isGreen ? Colors.green : Colors.amber;
    final label = isGreen ? s.idealNap : s.emergencyNapPrediction;
    final start = TimeUtils.fmtTOD(r!.suggestedStart!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isGreen ? Colors.green : Colors.amber,
              ),
            ),
            TextSpan(
              text: '${r!.totalDisplayMin} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '  •  '),
            TextSpan(text: '${r!.scopeEmoji} ${s.translateScope(r!.scope)}'),
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
