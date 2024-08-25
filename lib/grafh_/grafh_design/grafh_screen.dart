import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TradeChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradeChartProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<TradeChartProvider>(
                  builder: (context, provider, child) {
                    return LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: provider.dataPoints,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 20,
                          verticalInterval: 20,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        minX: 0,
                        maxX: provider.dataSize.toDouble(),
                        minY: -80,
                        maxY: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 50,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$100 ↓',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 100,
              child: Consumer<TradeChartProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      provider.currentValue.toStringAsFixed(3),
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TradeChartProvider with ChangeNotifier {
  List<FlSpot> dataPoints = [];
  Random random = Random();
  double currentValue = 0;
  final int dataSize = 100;
  Timer? _updateTimer;
  Timer? _valueTimer;

  TradeChartProvider() {
    _generateInitialData();
    _startPeriodicUpdate();
    _startValueUpdate();
  }

  void _generateInitialData() {
    currentValue = random.nextDouble() * 100 - 80;
    for (int i = 0; i < dataSize; i++) {
      dataPoints.add(FlSpot(i.toDouble(), currentValue));
      _updateValue();
    }
  }

  void _updateValue() {
    double change = (random.nextDouble() - 0.5) * 10;
    currentValue = (currentValue + change).clamp(-80, 20);
    notifyListeners();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateValue();
      if (dataPoints.length >= dataSize) {
        dataPoints.removeAt(0);
      }
      dataPoints.add(FlSpot(dataPoints.length.toDouble(), currentValue));
      notifyListeners();
    });
  }

  void _startValueUpdate() {
    _valueTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateValue();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _valueTimer?.cancel();
    super.dispose();
  }
}
