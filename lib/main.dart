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

const String exampleJsonData2 = '''
[
    {"y": 8},
    {"y": 10},
    {"y": 1}
]
''';

const String exampleJsonData3 = '''
[
    {"title": "A", "value": 40, "color": "blue"},
    {"title": "B", "value": 30},
    {"title": "C", "value": 15, "color": "green"},
    {"title": "D", "value": 15}
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
                child: BarChartWidget(jsonData: exampleJsonData2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: PieChartWidget(jsonData: exampleJsonData3),
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
  final String jsonData;

  const BarChartWidget({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    // 解析JSON數據
    var data = jsonDecode(jsonData);
    var barGroups = _convertJsonToBarGroups(data);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(barGroups), // 根據數據動態計算maxY
        barTouchData: BarTouchData(enabled: false),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  // 將JSON數據轉換為BarChart所需的格式
  List<BarChartGroupData> _convertJsonToBarGroups(dynamic data) {
    List<BarChartGroupData> barGroups = [];
    for (var i = 0; i < data.length; i++) {
      var record = data[i];
      double y = record['y'].toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(y: y, colors: [Colors.lightBlueAccent])
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  // 計算maxY值
  double _calculateMaxY(List<BarChartGroupData> barGroups) {
    double maxY = 0;
    for (var group in barGroups) {
      for (var rod in group.barRods) {
        if (rod.y > maxY) maxY = rod.y;
      }
    }
    return maxY;
  }

  FlTitlesData _buildTitlesData() => FlTitlesData(
        show: true,
      );
}

class PieChartWidget extends StatelessWidget {
  final String jsonData;

  const PieChartWidget({super.key, required this.jsonData});

  @override
  Widget build(BuildContext context) {
    var data = jsonDecode(jsonData);
    var sections = _convertJsonToPieChartSections(data);

    return PieChart(
      PieChartData(centerSpaceRadius: 40, sections: sections),
    );
  }

  // 將JSON數據轉換為PieChart的sections
  List<PieChartSectionData> _convertJsonToPieChartSections(dynamic data) {
    List<PieChartSectionData> sections = [];
    for (var item in data) {
      var title = item['title'];
      var value = item['value'].toDouble();
      var color = _getColorFromString(item['color']);

      sections.add(
        PieChartSectionData(
          title: title,
          value: value,
          color: color,
          radius: 50,
        ),
      );
    }
    return sections;
  }

  // 將字符串顏色轉換為Flutter顏色
  Color _getColorFromString(String? colorStr) {
    switch (colorStr) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return _getRandomColor();
    }
  }

  // 生成隨機顏色
  Color _getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }
}
