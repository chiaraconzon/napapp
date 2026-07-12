import 'package:flutter/material.dart';

// Circular widget used to display a selectable timer duration (HH:MM)
class AlarmCircleTimer extends StatelessWidget {
  // Duration shown inside the circle
  final Duration duration;

  // Callback executed when the circle is tapped
  final VoidCallback? onTap;

  // Indicates whether this timer is currently selected
  final bool selected;

  const AlarmCircleTimer({
    super.key,
    required this.duration,
    this.onTap,
    this.selected = false,
  });

  // Converts a Duration into HH:MM format
  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Access the current app theme
    final theme = Theme.of(context);

    return GestureDetector(
      // Detects tap on the timer circle
      onTap: onTap,
      child: Container(
        // Circular container dimensions
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          // Makes the container circular
          shape: BoxShape.circle,

          // Highlights the background when selected
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,

          // Changes border color and thickness depending on selection
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 3 : 1.5,
          ),
        ),

        // Centers the formatted duration inside the circle
        child: Center(
          child: Text(
            _format(duration),
            style: TextStyle(
              // Text appearance
              fontSize: 24,
              fontWeight: FontWeight.bold,

              // Uses primary color when selected
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
