import 'package:flutter/material.dart';

class TimerPicker extends StatefulWidget {
  final Duration duration;
  final Function(Duration) onDurationChanged;

  const TimerPicker({
    super.key,
    required this.duration,
    required this.onDurationChanged,
  });

  @override
  State<TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  int hour = 0;
  int minute = 0;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  void _notifyChange() {
    widget.onDurationChanged(Duration(hours: hour, minutes: minute));
  }

  @override
  void initState() {
    super.initState();

    _syncFromDuration(widget.duration);

    hourController = FixedExtentScrollController(initialItem: hour);
    minuteController = FixedExtentScrollController(initialItem: minute);
  }

  void _syncFromDuration(Duration d) {
    hour = d.inHours;
    minute = d.inMinutes % 60;
  }

  @override
  void didUpdateWidget(covariant TimerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      final newHour = widget.duration.inHours;
      final newMinute = widget.duration.inMinutes % 60;

      setState(() {
        hour = newHour;
        minute = newMinute;
      });

      hourController.jumpToItem(newHour);
      minuteController.jumpToItem(newMinute);
    }
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // fondamentale per dialog
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWheel(
            max: 24,
            controller: hourController,
            currentValue: hour,
            onChanged: (val) {
              setState(() => hour = val);
              _notifyChange();
            },
            label: "hours",
          ),

          const Text(":", style: TextStyle(fontSize: 24)),

          _buildWheel(
            max: 60,
            controller: minuteController,
            currentValue: minute,
            onChanged: (val) {
              setState(() => minute = val);
              _notifyChange();
            },
            label: "minutes",
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required int max,
    required int currentValue,
    required FixedExtentScrollController controller,
    required Function(int) onChanged,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: max,
                builder: (context, index) {
                  final isSelected = index == currentValue;
                  final isNear =
                      index == currentValue - 1 || index == currentValue + 1;

                  return Center(
                    child: Opacity(
                      opacity: isSelected ? 1 : (isNear ? 0.6 : 0.3),
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 26 : (isNear ? 20 : 18),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
