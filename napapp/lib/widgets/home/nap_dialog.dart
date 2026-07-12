import 'package:flutter/material.dart';
import '../../models/nap_models.dart';
import '../../screens/app_strings.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

// Displays a confirmation dialog before starting the recommended nap
void showNapDialog({
  required BuildContext context,
  required NapResult napResult,
  required AppStrings s,
  required VoidCallback onNapStarted,
}) {
  // Current time (fixed for testing purposes)
  // final now = TimeOfDay.now();
  final now = const TimeOfDay(hour: 18, minute: 0);

  // Suggested nap start time calculated by the algorithm
  final suggestedTime = napResult.suggestedStart!;

  // Converts current time to minutes from midnight
  final nowMinutes = now.hour * 60 + now.minute;

  // Converts suggested time to minutes from midnight
  final suggestedMinutes = suggestedTime.hour * 60 + suggestedTime.minute;

  // Calculates the absolute difference between current and suggested time
  final difference = (nowMinutes - suggestedMinutes).abs();

  // WRONG TIME
  // If the current time differs from the suggested time by more than 30 minutes,
  // warn the user that this is not the ideal moment for a nap
  if (difference > 30) {
    showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : null,

        // Dialog title
        title: const Text("Attenzione"),

        // Explains that the current time is not recommended
        content: Text(
          "Questo non sembra il momento ideale "
          "per il tuo pisolino.\n\n"
          "L'orario consigliato è "
          "${suggestedTime.format(context)}.",
        ),

        actions: [
          // Closes the warning dialog
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
            },

            child: const Text("OK"),
          ),
        ],
      ),
    );

    return;
  }

  // CORRECT TIME
  // Asks the user for confirmation before starting the nap timer
  showDialog(
    context: context,

    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : null,

      // Dialog title
      title: const Text("Inizia il pisolino?"),

      // Shows the recommended nap duration
      content: Text(
        "Vuoi iniziare il tuo pisolino "
        "di ${napResult.totalDisplayMin} minuti?",
      ),

      actions: [
        // Cancels the operation and closes the dialog
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },

          child: const Text("No"),
        ),

        // Starts the nap
        FilledButton(
          onPressed: () {
            // Closes the dialog
            Navigator.pop(ctx);

            // Executes callback when the nap starts
            onNapStarted();

            // Starts the system timer with the recommended duration
            FlutterAlarmClock.createTimer(length: napResult.totalDisplayMin);

            // Displays a confirmation message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.alarmTimerStarted(napResult.totalDisplayMin)),
              ),
            );
          },

          child: const Text("Sì"),
        ),
      ],
    ),
  );
}
