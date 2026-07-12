import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Widget that allows the user to select a duration
// using Cupertino-style scroll wheels
class ChooseTime extends StatefulWidget {
  // Currently selected duration
  final Duration duration;

  // Callback triggered whenever the selected duration changes
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
  // Currently selected hours and minutes
  late int hours;
  late int minutes;

  // Controllers used to position the scroll wheels
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();

    // Initializes the picker values from the provided duration
    hours = widget.duration.inHours;
    minutes = widget.duration.inMinutes % 60;

    // Positions the pickers on the initial values
    hourController = FixedExtentScrollController(initialItem: hours);
    minuteController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    // Releases the picker controllers
    hourController.dispose();
    minuteController.dispose();

    super.dispose();
  }

  // Sends the updated duration to the parent widget
  void updateTime() {
    widget.onChanged(Duration(hours: hours, minutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Height of the picker area
      height: 150,

      child: Row(
        children: [
          // Hours picker
          Expanded(
            child: CupertinoPicker(
              scrollController: hourController,

              // Height of each picker item
              itemExtent: 40,

              // Enlarges the selected item
              useMagnifier: true,

              magnification: 1.2,

              // Updates the selected hour
              onSelectedItemChanged: (value) {
                setState(() {
                  hours = value;
                });

                updateTime();
              },

              // Generates hour values from 0 to 12
              children: List.generate(
                13,
                (index) => Center(child: Text("$index h")),
              ),
            ),
          ),

          // Minutes picker
          Expanded(
            child: CupertinoPicker(
              scrollController: minuteController,

              // Height of each picker item
              itemExtent: 40,

              // Enlarges the selected item
              useMagnifier: true,

              magnification: 1.2,

              // Updates the selected minutes
              onSelectedItemChanged: (value) {
                setState(() {
                  minutes = value;
                });

                updateTime();
              },

              // Generates minute values from 0 to 59
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
