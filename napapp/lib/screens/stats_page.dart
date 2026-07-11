import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/stats/stats_header.dart';
import '../widgets/stats/sleep_score_card.dart';
import '../widgets/stats/stats_grid.dart';
import '../widgets/stats/sleep_chart.dart';
import '../widgets/stats/sleep_debt_card.dart';
import '../widgets/stats/weekly_insight_card.dart';
import '../models/sleep.dart';

class StatsPage extends StatelessWidget {
  final Map<DateTime, SleepData> sleepData;

  StatsPage({
    super.key,
    required this.sleepData
    });

  final List<FlSpot> sampleData = [
    const FlSpot(1, 3), // Lunedì: 3 attività
    const FlSpot(2, 5), // Martedì: 5 attività
    const FlSpot(3, 2), // Mercoledì: 2 attività
    const FlSpot(4, 8), // Giovedì: 8 attività
    const FlSpot(5, 4), // Venerdì: 4 attività
  ];

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
              const SleepChart(),
              const SizedBox(height: 28),
              const SleepDebtCard(),
              const SizedBox(height: 24),
              const WeeklyInsightCard(),
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