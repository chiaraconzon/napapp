import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
import '../widgets/stats/stats_header.dart';
import '../widgets/stats/stats_grid.dart';
import '../widgets/stats/sleep_chart.dart';
import '../widgets/stats/sleep_debt_card.dart';
import '../widgets/stats/weekly_insight_card.dart';
import '../models/sleep.dart';

// ignore: must_be_immutable
class StatsPage extends StatefulWidget {
  // Data for the stat widgets
  final List<SleepData> sleepData;
  double sds;

  StatsPage({super.key, required this.sleepData, required this.sds});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late List<SleepData> _sleepDataList;
  late List<SleepData> _data1week;
  late List<SleepData> _data2week;

  @override
  void initState() {
    super.initState();
    _sleepDataList = widget.sleepData;
    _data1week = get7Days(_sleepDataList);
    _data2week = getNDays(_sleepDataList, 14);
  }

  // Converts the list into a map: not used but could be useful for future developments
  Map<DateTime, SleepData> ListToMap(List<SleepData> sleepDataList) {
    Map<DateTime, SleepData> mapData = {
      for (var elem in sleepDataList) elem.date: elem,
    };

    return mapData;
  }

  // Get the most recent 7 days of sleep data and sorts them in cronological order
  List<SleepData> get7Days(List<SleepData> sleepDataList) {
    List<SleepData> data7days = sleepDataList.sublist(0, 7);
    data7days.sort((a, b) => a.date.compareTo(b.date));

    return data7days;
  }

  // Get the most recent N days of sleep data and sorts them in cronological order
  List<SleepData> getNDays(List<SleepData> sleepDataList, int n) {
    if (n < 1) return [];

    List<SleepData> dataNdays = sleepDataList.sublist(0, n);
    dataNdays.sort((a, b) => a.date.compareTo(b.date));

    return dataNdays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SizedBox(height: 10),
              const StatsHeader(),

              // Plot showing the amount of hours of sleep in the past 7 days
              const SizedBox(height: 28),
              SleepChart(sleepData: _data1week),

              // Grid that shows: average sleep time in the past week, number of naps taken this week (latter is a mock value)
              const SizedBox(height: 10),
              StatsGrid(sleepData: _data1week),

              // Shows the amount of hours of sleep debt of the day, as calculated by the app's algorithm
              const SizedBox(height: 28),
              SleepDebtCard(sds: widget.sds),

              // Shows the change in average sleep time compared to the previous week
              const SizedBox(height: 24),
              WeeklyInsightCard(sleepData2weeks: _data2week),
            ],
          ),
        ),
      ),
    );
  }
}
