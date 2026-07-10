import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChooseTime extends StatefulWidget {
  final Duration duration;
  final Function(Duration) onChanged;

  const ChooseTime({
    super.key,
    required this.duration,
    required this.onChanged,
  });

  @override
  State<ChooseTime> createState() => _ChooseTimeState();
}

class _ChooseTimeState extends State<ChooseTime> {
  late int hours;
  late int minutes;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();

    hours = widget.duration.inHours;
    minutes = widget.duration.inMinutes % 60;

    hourController = FixedExtentScrollController(initialItem: hours);

    minuteController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void updateTime() {
    widget.onChanged(Duration(hours: hours, minutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,

      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: hourController,

              itemExtent: 40,

              useMagnifier: true,

              magnification: 1.2,

              onSelectedItemChanged: (value) {
                setState(() {
                  hours = value;
                });

                updateTime();
              },

              children: List.generate(
                13,
                (index) => Center(child: Text("$index h")),
              ),
            ),
          ),

          Expanded(
            child: CupertinoPicker(
              scrollController: minuteController,

              itemExtent: 40,

              useMagnifier: true,

              magnification: 1.2,

              onSelectedItemChanged: (value) {
                setState(() {
                  minutes = value;
                });

                updateTime();
              },

              children: List.generate(
                60,
                (index) => Center(child: Text("$index min")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
