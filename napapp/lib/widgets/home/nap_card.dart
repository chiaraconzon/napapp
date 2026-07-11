import 'dart:async';
import 'package:flutter/material.dart';

import '../../screens/app_strings.dart';
import '../../models/nap_models.dart';
import 'nap_dialog.dart';

class NapCard extends StatefulWidget {
  final NapResult r;
  final bool isEnglish;
  final String Function(TimeOfDay) fmtTOD;
  final Color Function(NapZone) zoneColor;
  final VoidCallback onRequestNewNap;

  const NapCard({
    super.key,
    required this.r,
    required this.isEnglish,
    required this.fmtTOD,
    required this.zoneColor,
    required this.onRequestNewNap,
  });

  @override
  State<NapCard> createState() => _NapCardState();
}

class _NapCardState extends State<NapCard> {
  Timer? napTimer;
  DateTime? napStartTime;

  void startNapTimer() {
    napTimer?.cancel();

    napTimer = Timer(Duration(seconds: widget.r.totalDisplayMin), () {
      if (!mounted) return;

      setState(() {
        widget.r.status = NapStatus.completed;
      });
    });
  }

  @override
  void dispose() {
    napTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.isEnglish);

    final color = widget.zoneColor(widget.r.zone);

    String label;

    switch (widget.r.status) {
      case NapStatus.running:
        label = "Pisolino in corso";
        break;

      case NapStatus.completed:
        label = "Pisolino completato";
        break;

      case NapStatus.interrupted:
        label = "Pisolino interrotto";
        break;

      case NapStatus.suggested:
        label = widget.r.zone == NapZone.orange
            ? s.napEmergencyLabel
            : s.napLabel;
        break;
    }

    final start = widget.fmtTOD(widget.r.suggestedStart!);

    final end = widget.fmtTOD(widget.r.suggestedEnd!);

    return Card(
      elevation: 3,

      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),

        side: BorderSide(color: color, width: 2),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: () {
          // SE IL PISOLINO È PARTITO
          if (widget.r.status == NapStatus.running) {
            showDialog(
              context: context,

              builder: (ctx) {
                return AlertDialog(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surface
                      : null,
                  title: const Text("Pisolino in corso"),

                  content: const Text("Vuoi interrompere il pisolino?"),

                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },

                      child: const Text("Continua"),
                    ),

                    FilledButton(
                      onPressed: () {
                        napTimer?.cancel();

                        final sleptMinutes = napStartTime == null
                            ? 0
                            : DateTime.now()
                                  .difference(napStartTime!)
                                  .inMinutes;

                        setState(() {
                          widget.r.status = NapStatus.interrupted;
                        });

                        Navigator.pop(ctx);

                        showDialog(
                          context: context,

                          builder: (ctx2) {
                            final tooShort = sleptMinutes < 10;

                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.surface
                                  : null,

                              title: const Text("Pisolino interrotto"),

                              content: Text(
                                tooShort
                                    ? "Hai dormito per $sleptMinutes minuti.\n\n"
                                          "È un po' poco. Vuoi provare a fare un altro pisolino?"
                                    : "Hai dormito per $sleptMinutes minuti.\n\n"
                                          "Può bastare così!",
                              ),

                              actions: [
                                if (tooShort)
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(ctx2);

                                      widget.onRequestNewNap();
                                    },

                                    child: const Text("Nuovo pisolino"),
                                  ),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx2);
                                  },

                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      child: const Text("Interrompi"),
                    ),
                  ],
                );
              },
            );

            return;
          }

          // ALTRIMENTI APRE IL DIALOG NORMALE
          showNapDialog(
            context: context,

            napResult: widget.r,

            s: s,

            onNapStarted: () {
              setState(() {
                widget.r.status = NapStatus.running;
                napStartTime = DateTime.now();
              });

              startNapTimer();
            },
          );
        },

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

              child: Icon(
                switch (widget.r.status) {
                  NapStatus.running => Icons.timer,

                  NapStatus.completed => Icons.check_circle,

                  NapStatus.interrupted => Icons.pause_circle,

                  NapStatus.suggested => Icons.bedtime,
                },

                color: color,

                size: 28,
              ),
            ),

            title: Text(
              '${widget.r.scopeEmoji} $label',

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
                      Icon(
                        Icons.access_time,

                        size: 16,

                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '$start - $end',

                        style: TextStyle(
                          fontSize: 15,

                          color: Theme.of(context).colorScheme.onSurface,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    s.napDetails(
                      widget.r.totalDisplayMin,
                      s.translateScope(widget.r.scope),
                    ),

                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  if (widget.r.hasInertiaWarning)
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
