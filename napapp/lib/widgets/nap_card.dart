import 'package:flutter/material.dart';
import '../screens/app_strings.dart';
import '../models/nap_models.dart';

class NapCard extends StatelessWidget {
  final NapResult r;
  final bool isEnglish;
  final String Function(TimeOfDay) fmtTOD;
  final Color Function(NapZone) zoneColor;

  const NapCard({
    super.key,
    required this.r,
    required this.isEnglish,
    required this.fmtTOD,
    required this.zoneColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(isEnglish);
    final color = zoneColor(r.zone);
    final label = r.zone == NapZone.orange ? s.napEmergencyLabel : s.napLabel;
    final start = fmtTOD(r.suggestedStart!);
    final end = fmtTOD(r.suggestedEnd!);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withOpacity(0.7), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bedtime, color: color, size: 28),
          ),
          title: Text(
            '${r.scopeEmoji} $label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: color,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: color),
                    const SizedBox(width: 5),
                    Text(
                      '$start - $end',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  s.napDetails(r.totalDisplayMin, s.translateScope(r.scope)),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (r.hasInertiaWarning) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 13,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.inertiaWarning,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// CARD PISOLINO
// -----------------------------------------------------------------------
