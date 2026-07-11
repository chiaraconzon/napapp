import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/stats/stats_header.dart';
import '../widgets/stats/sleep_score_card.dart';
import '../widgets/stats/stats_grid.dart';
import '../widgets/stats/sleep_chart.dart';
import '../widgets/stats/sleep_debt_card.dart';
import '../widgets/stats/weekly_insight_card.dart';
import '../models/sleep.dart';

class StatsPage extends StatefulWidget {
  final List<SleepData> sleepData;
  double sds;

  StatsPage({
    super.key,
    required this.sleepData,
    required this.sds
    });

  final List<FlSpot> sampleData = [
    const FlSpot(1, 3), // Lunedì: 3 attività
    const FlSpot(2, 5), // Martedì: 5 attività
    const FlSpot(3, 2), // Mercoledì: 2 attività
    const FlSpot(4, 8), // Giovedì: 8 attività
    const FlSpot(5, 4), // Venerdì: 4 attività
  ];

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>{

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

  Map<DateTime, SleepData> ListToMap (List<SleepData> sleepDataList) {
    Map<DateTime, SleepData> mapData = {
      for (var elem in sleepDataList) elem.date : elem
    };

    return mapData;
  }

  List<SleepData> get7Days (List<SleepData> sleepDataList) {
    List<SleepData> data7days = sleepDataList.sublist(0,8);
    data7days.sort((a, b) => a.date.compareTo(b.date));

    return data7days;
  }

  List<SleepData> getNDays (List<SleepData> sleepDataList, int n) {
    if(n<1) return [];

    List<SleepData> dataNdays = sleepDataList.sublist(0,n+1);
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
              SizedBox(height: 10),
              const StatsHeader(),
              SizedBox(height: 10),
              SleepScoreCard(),
              const SizedBox(height: 10),
              const StatsGrid(),

              const SizedBox(height: 28),
              SleepChart(
                sleepData: _data1week,
              ),

              const SizedBox(height: 28),
              SleepDebtCard(
                sds: widget.sds
              ),

              const SizedBox(height: 24),
              WeeklyInsightCard(
                sleepData2weeks: _data2week,
              ),
            ],

            /*
              SizedBox(
                height: 200, // Imposta un'altezza fissa
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: false,
                    ), // Nasconde la griglia di sfondo
                    titlesData: FlTitlesData(
                      show: true,
                    ), // Mostra i numeri sugli assi
                    borderData: FlBorderData(
                      show: true,
                    ), // Mostra il bordo del grafico
                    lineBarsData: [
                      LineChartBarData(
                        spots: sampleData, // Carica i dati definiti sopra
                        isCurved: true, // Rende la linea curva e morbida
                        color: Colors.blue, // Colore della linea
                        barWidth: 4, // Spessore della linea
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color.fromARGB(
                            124,
                            33,
                            149,
                            243,
                          ), // Colore della linea
                        ), // Ombra sotto la linea
                      ),
                    ],
                  ),
                ),
              ),*/
          ),
        ),
      ),
    );
  }
}
