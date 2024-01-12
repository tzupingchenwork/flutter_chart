import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Chart Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const String exampleJsonData = '''
[
  {"x": 0, "y": 0},
  {"x": 1, "y": 2},
  {"x": 2, "y": 5},
  {"x": 3, "y": 3},
  {"x": 4, "y": 4},
  {"x": 5, "y": 3},
  {"x": 6, "y": 4}
]
''';

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: LineChartWidget(jsonData: exampleJsonData),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: BarChartWidget(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: PieChartWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

class LineChartWidget extends StatelessWidget {
  final String jsonData;

  const LineChartWidget({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    // 解析JSON數據
    var data = jsonDecode(jsonData);
    var lineBarsData = _convertJsonToLineBarsData(data);
    // 計算minX, maxX, minY, maxY
    double minX =
        lineBarsData.isNotEmpty ? lineBarsData.first.spots.first.x : 0;
    double maxX = minX;
    double minY =
        lineBarsData.isNotEmpty ? lineBarsData.first.spots.first.y : 0;
    double maxY = minY;

    for (var barData in lineBarsData) {
      for (var spot in barData.spots) {
        minX = min(minX, spot.x);
        maxX = max(maxX, spot.x);
        minY = min(minY, spot.y);
        maxY = max(maxY, spot.y);
      }
    }

    return LineChart(
      LineChartData(
        gridData: _buildGridData(),
        titlesData: _buildTitlesData(),
        borderData: _buildBorderData(),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: lineBarsData,
      ),
    );
  }

  // 將JSON數據轉換為LineChart所需的格式
  List<LineChartBarData> _convertJsonToLineBarsData(dynamic data) {
    List<FlSpot> spots = [];
    for (var record in data) {
      double x = record['x'].toDouble();
      double y = record['y'].toDouble();
      spots.add(FlSpot(x, y));
    }

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        colors: gradientColors, // 確保gradientColors已定義
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          colors:
              gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ];
  }

  FlGridData _buildGridData() => FlGridData(
        show: false,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: const Color(0xff37434d),
          strokeWidth: 1,
        ),
      );

  FlTitlesData _buildTitlesData() => FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          reservedSize: 28,
          margin: 12,
        ),
      );

  FlBorderData _buildBorderData() => FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      );
}

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
                color: Color(0xff7589a2),
                fontWeight: FontWeight.bold,
                fontSize: 14),
            margin: 20,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return 'M';
                case 1:
                  return 'T';
                case 2:
                  return 'W';
                case 3:
                  return 'T';
                case 4:
                  return 'F';
                case 5:
                  return 'S';
                case 6:
                  return 'S';
              }
              return '';
            },
          ),
          leftTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(y: 8, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(y: 10, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(y: 14, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(y: 15, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 4, barRods: [
            BarChartRodData(y: 13, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 5, barRods: [
            BarChartRodData(y: 10, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
          BarChartGroupData(x: 6, barRods: [
            BarChartRodData(y: 5, colors: [Colors.lightBlueAccent])
          ], showingTooltipIndicators: [
            0
          ]),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(centerSpaceRadius: 40, sections: [
        PieChartSectionData(
            value: 40, color: Colors.blue, title: 'Blue', radius: 50),
        PieChartSectionData(
            value: 30, color: Colors.orange, title: 'Orange', radius: 50),
        PieChartSectionData(
            value: 15, color: Colors.green, title: 'Green', radius: 50),
        PieChartSectionData(
            value: 15, color: Colors.red, title: 'Red', radius: 50),
      ]),
    );
  }
}
