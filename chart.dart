import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final List<ChartData> chartData = [
    ChartData('IQ', 10, 20, 30, 100),
    ChartData('ADHD', 15, 25, 35, 101),
    ChartData('MMSE', 11, 22, 33, 102),
    ChartData('OCD', 12, 23, 34, 103),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text('Bar Chart'),
      ),
      body: Center(
          child: Container(
              child: SfCartesianChart(primaryXAxis: CategoryAxis(), series: [
        StackedColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData ch, _CH) => ch.x,
            yValueMapper: (ChartData ch, _CH) => ch.y1),
        StackedColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData ch, _CH) => ch.x,
            yValueMapper: (ChartData ch, _CH) => ch.y2),
        StackedLineSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData ch, _CH) => ch.x,
            yValueMapper: (ChartData ch, _CH) => ch.y3),
        StackedLineSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData ch, _CH) => ch.x,
            yValueMapper: (ChartData ch, _CH) => ch.y4)
      ]))),
    );
  }
}

class ChartData {
  final String x;
  final int y1, y2, y3, y4;

  ChartData(this.x, this.y1, this.y2, this.y3, this.y4);
}
