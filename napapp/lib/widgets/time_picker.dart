import 'package:flutter/material.dart';

class AlarmCircleTimer extends StatelessWidget {
  final Duration duration;
  final VoidCallback? onTap;
  final bool selected;

  const AlarmCircleTimer({
    super.key,
    required this.duration,
    this.onTap,
    this.selected = false,
  });

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surface,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 3 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            _format(duration),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
