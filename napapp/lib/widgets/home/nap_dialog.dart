import 'package:flutter/material.dart';
import '../../models/nap_models.dart';
import '../../screens/app_strings.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

void showNapDialog({
  required BuildContext context,
  required NapResult napResult,
  required AppStrings s,
  required VoidCallback onNapStarted,
}) {
  //  final now = TimeOfDay.now();
  final now = const TimeOfDay(hour: 18, minute: 0);
  final suggestedTime = napResult.suggestedStart!;

  final nowMinutes = now.hour * 60 + now.minute;

  final suggestedMinutes = suggestedTime.hour * 60 + suggestedTime.minute;

  final difference = (nowMinutes - suggestedMinutes).abs();

  // ORARIO SBAGLIATO
  if (difference > 30) {
    showDialog(
      context: context,

      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : null,
        title: const Text("Attenzione"),

        content: Text(
          "Questo non sembra il momento ideale "
          "per il tuo pisolino.\n\n"
          "L'orario consigliato è "
          "${suggestedTime.format(context)}.",
        ),

        actions: [
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

  // ORARIO CORRETTO
  showDialog(
    context: context,

    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : null,
      title: const Text("Inizia il pisolino?"),

      content: Text(
        "Vuoi iniziare il tuo pisolino "
        "di ${napResult.totalDisplayMin} minuti?",
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },

          child: const Text("No"),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);

            onNapStarted();

            FlutterAlarmClock.createTimer(length: napResult.totalDisplayMin);

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
