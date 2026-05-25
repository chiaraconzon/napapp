import 'package:flutter/material.dart';

class TimerPicker extends StatefulWidget {
  const TimerPicker({super.key});

  @override
  State<TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  int hour = 0;
  int minute = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheel(
          max: 24,
          currentValue: hour,
          onChanged: (val) => setState(() => hour = val),
        ),

        const Text(":", style: TextStyle(fontSize: 24)),

        _buildWheel(
          max: 60,
          currentValue: minute,
          onChanged: (val) => setState(() => minute = val),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required int max,
    required int currentValue,
    required Function(int) onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 120,

            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),

              onSelectedItemChanged: onChanged,

              childDelegate: ListWheelChildBuilderDelegate(
                childCount: max,

                builder: (context, index) {
                  final isSelected = index == currentValue;
                  final isNear =
                      (index == currentValue - 1 || index == currentValue + 1);

                  double opacity = 0.3;
                  double size = 18;

                  if (isSelected) {
                    opacity = 1.0;
                    size = 26;
                  } else if (isNear) {
                    opacity = 0.6;
                    size = 20;
                  }

                  return Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: size,
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
          Text(max == 24 ? "hours" : "minutes"),
        ],
      ),
    );
  }
}
