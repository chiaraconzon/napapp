import 'package:flutter/material.dart';

class AlarmChoiceButton extends StatelessWidget {
  final int index;
  final int minutes;
  final int selectedIndex;
  final Function(int) onSelected;

  const AlarmChoiceButton({
    super.key,
    required this.index,
    required this.minutes,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    final label =
        '${minutes ~/ 60}'.padLeft(2, '0') +
        ':' +
        '${minutes % 60}'.padLeft(2, '0');

    return OutlinedButton(
      onPressed: () => onSelected(index),
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(
          color: isSelected
              ? const Color.fromARGB(255, 241, 127, 5)
              : Theme.of(context).colorScheme.primary,
          width: isSelected ? 3 : 2,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.all(25),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: isSelected
              ? const Color.fromARGB(255, 241, 127, 5)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
