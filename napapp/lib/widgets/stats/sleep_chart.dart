import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:napapp/models/sleep.dart';

class SleepChart extends StatelessWidget {
  final List<SleepData> sleepData;
<<<<<<< HEAD

  SleepChart({
    super.key,
    required this.sleepData
  });

  // Get a list of the hours of sleep of each day, 0 if the data is missing
  List<double> getHoursOfSleep(List<SleepData> sleepData) {
    List<double> hoursOfSleep = [];

    for(int i = 0; i < 7; i++) {
      int mins = (sleepData[i].minutesAsleep != null) ? sleepData[i].minutesAsleep! : 0;
      double hours = mins/60.0;
      hoursOfSleep.add(hours);
    }

    return hoursOfSleep;
  }

  // Create labels for the plot, the labels being the date in form DD.MM
  List<String> getLabels(List<SleepData> sleepData) {
    List<String> labels = [];

    for(int i = 0; i < 7; i++) {
      DateTime date = sleepData[i].date;
      String day = "${date.day}".padLeft(2,'0');
      String month = "${date.month}".padLeft(2,'0');
      String label = "$day.$month";

      labels.add(label);
    }

    return labels;
  }

  // Create a list of spots for the plot, x label is 1:6, y label are the hours of sleep
  List<FlSpot> getSpots(List<double> hrs) {
    List<FlSpot> spots = [];

    for(int i = 0; i < 7; i++) {
      FlSpot spot = FlSpot(i.toDouble(),hrs[i]);
      spots.add(spot);
    }

    return spots;
  }
=======
>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440

  SleepChart({super.key, required this.sleepData});

  // Get a list of the hours of sleep of each day, 0 if the data is missing
  List<double> getHoursOfSleep(List<SleepData> sleepData) {
    List<double> hoursOfSleep = [];

    for (int i = 0; i < 7; i++) {
      int mins = (sleepData[i].minutesAsleep != null)
          ? sleepData[i].minutesAsleep!
          : 0;
      double hours = mins / 60.0;
      hoursOfSleep.add(hours);
    }

    return hoursOfSleep;
  }

  // Create labels for the plot, the labels being the date in form DD.MM
  List<String> getLabels(List<SleepData> sleepData) {
    List<String> labels = [];

    for (int i = 0; i < 7; i++) {
      DateTime date = sleepData[i].date;
      String day = "${date.day}".padLeft(2, '0');
      String month = "${date.month}".padLeft(2, '0');
      String label = "$day.$month";

      labels.add(label);
    }

    return labels;
  }

  // Create a list of spots for the plot, x label is 1:6, y label are the hours of sleep
  List<FlSpot> getSpots(List<double> hrs) {
    List<FlSpot> spots = [];

    for (int i = 0; i < 7; i++) {
      FlSpot spot = FlSpot(i.toDouble(), hrs[i]);
      spots.add(spot);
    }

    return spots;
  }

  // Plot the progression of the hours of sleep
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hoursOfSleep = getHoursOfSleep(sleepData);
<<<<<<< HEAD
    final labels = getLabels(sleepData);    
    
=======
    final labels = getLabels(sleepData);

>>>>>>> f6cb9ed2f7722f48f31b590520c9086b7dea0440
    final spots = getSpots(hoursOfSleep);

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),

        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sleep Trend",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,

            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,

                gridData: const FlGridData(show: false),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, interval: 1),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,

                      reservedSize: 35,

                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}h",
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 1,
                      showTitles: true,

                      getTitlesWidget: (value, meta) {
                        return Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots, // Altezze

                    isCurved: true,

                    barWidth: 4,

                    color: theme.colorScheme.secondary,

                    dotData: const FlDotData(show: false),

                    belowBarData: BarAreaData(
                      show: true,

                      color: theme.colorScheme.secondary.withOpacity(.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
