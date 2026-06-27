import 'package:flutter/material.dart';
import '../models/nap_models.dart';
import '../algorithms/nap_algorithm.dart';
import '../screens/app_strings.dart';

class DebugZonesBox extends StatelessWidget {
  final ZoneLimits lim;
  final bool isEnglish;

  const DebugZonesBox({super.key, required this.lim, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔧 DEBUG ZONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),

          _row(
            s.zoneGreen,
            '${NapAlgorithm.fmtMin(lim.greenStart)} → ${NapAlgorithm.fmtMin(lim.greenEnd)}',
            Colors.green,
          ),
          _row(
            s.zoneYellow,
            '${NapAlgorithm.fmtMin(lim.greenEnd)} → ${NapAlgorithm.fmtMin(lim.yellowEnd)}',
            Colors.amber,
          ),
          _row(
            s.zoneOrange,
            '${NapAlgorithm.fmtMin(lim.yellowEnd)} → ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
            Colors.orange,
          ),
          _row(
            s.zoneRed,
            '${s.zoneBeyond} ${NapAlgorithm.fmtMin(lim.orangeEnd)}',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            val,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
