import 'dart:async';
import 'package:flutter/material.dart';

import '../../screens/app_strings.dart';
import '../../models/nap_models.dart';
import 'nap_dialog.dart';

// Card that displays the recommended nap and manages its lifecycle
// (suggested, running, interrupted and completed)
class NapCard extends StatefulWidget {
  // Nap data returned by the algorithm
  final NapResult r;

  // Current language
  final bool isEnglish;

  // Function used to format TimeOfDay values
  final String Function(TimeOfDay) fmtTOD;

  // Returns the color associated with the nap zone
  final Color Function(NapZone) zoneColor;

  // Callback used to request a new nap recommendation
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
  // Timer used to determine when the nap is completed
  Timer? napTimer;

  // Stores the time at which the nap started
  DateTime? napStartTime;

  // Starts the nap timer
  void startNapTimer() {
    // Cancels any previous timer
    napTimer?.cancel();

    // Starts a new timer with the nap duration
    napTimer = Timer(Duration(seconds: widget.r.totalDisplayMin), () {
      if (!mounted) return;

      // Updates the nap status when the timer ends
      setState(() {
        widget.r.status = NapStatus.completed;
      });
    });
  }

  @override
  void dispose() {
    // Releases timer resources
    napTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Localized strings
    final s = AppStrings(widget.isEnglish);

    // Color associated with the nap zone
    final color = widget.zoneColor(widget.r.zone);

    // Label shown in the card depending on nap status
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

    // Formats suggested start and end times
    final start = widget.fmtTOD(widget.r.suggestedStart!);

    final end = widget.fmtTOD(widget.r.suggestedEnd!);

    return Card(
      // Card appearance
      elevation: 3,

      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),

        side: BorderSide(color: color, width: 2),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        // Handles tap on the nap card
        onTap: () {
          // RUNNING NAP
          // Allows the user to interrupt the current nap
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
                    // Closes the dialog without interrupting the nap
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Continua"),
                    ),

                    // Stops the nap
                    FilledButton(
                      onPressed: () {
                        // Stops the timer
                        napTimer?.cancel();

                        // Calculates how many minutes the user actually slept
                        final sleptMinutes = napStartTime == null
                            ? 0
                            : DateTime.now()
                                  .difference(napStartTime!)
                                  .inMinutes;

                        // Updates nap status
                        setState(() {
                          widget.r.status = NapStatus.interrupted;
                        });

                        Navigator.pop(ctx);

                        // Shows interruption summary
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

                              // Shows a different message depending on nap duration
                              content: Text(
                                tooShort
                                    ? "Hai dormito per $sleptMinutes minuti.\n\n"
                                          "È un po' poco. Vuoi provare a fare un altro pisolino?"
                                    : "Hai dormito per $sleptMinutes minuti.\n\n"
                                          "Può bastare così!",
                              ),

                              actions: [
                                // Suggests requesting another nap if the previous one was too short
                                if (tooShort)
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(ctx2);
                                      widget.onRequestNewNap();
                                    },
                                    child: const Text("Nuovo pisolino"),
                                  ),

                                // Closes the dialog
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx2),
                                  child: const Text("Annulla"),
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

          // INTERRUPTED NAP
          // Allows the user to request a new recommendation
          if (widget.r.status == NapStatus.interrupted) {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surface
                      : null,

                  title: const Text("Pisolino interrotto"),

                  content: const Text("Vuoi impostare un nuovo pisolino?"),

                  actions: [
                    // Closes the dialog
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("No"),
                    ),

                    // Requests a new nap recommendation
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onRequestNewNap();
                      },
                      child: const Text("Sì"),
                    ),
                  ],
                );
              },
            );

            return;
          }

          // SUGGESTED OR COMPLETED NAP
          // Opens the confirmation dialog before starting a new nap.
          showNapDialog(
            context: context,
            napResult: widget.r,
            s: s,

            onNapStarted: () {
              // Updates nap status and stores the start time
              setState(() {
                widget.r.status = NapStatus.running;
                napStartTime = DateTime.now();
              });

              // Starts the nap timer
              startNapTimer();
            },
          );
        },

        child: Container(
          decoration: BoxDecoration(
            // Light background using the zone color
            color: color.withOpacity(0.07),

            borderRadius: BorderRadius.circular(15),
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),

            // Status icon
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

            // Card title
            title: Text(
              '${widget.r.scopeEmoji} $label',

              style: TextStyle(
                fontWeight: FontWeight.bold,

                fontSize: 17,

                color: color,
              ),
            ),

            // Card details
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Displays suggested start and end times
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

                  // Displays nap duration and purpose
                  Text(
                    s.napDetails(
                      widget.r.totalDisplayMin,
                      s.translateScope(widget.r.scope),
                    ),

                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  // Displays a warning if sleep inertia is expected
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
