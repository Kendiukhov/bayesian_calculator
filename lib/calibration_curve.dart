import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'models/event.dart';

class CalibrationCurve extends StatelessWidget {
  final List<Event> events;

  const CalibrationCurve({required this.events, super.key});

  @override
  Widget build(BuildContext context) {
    final data = _calculateCalibrationData(events);
    final brierScore = _calculateBrierScore(events);

    return SizedBox(
      height: 400,
      child: Column(
        children: [
          SfCartesianChart(
            title: ChartTitle(text: 'Calibration Curve'),
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: 'Predicted Probability'),
              minimum: 0,
              maximum: 1,
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Actual Frequency'),
              minimum: 0,
              maximum: 1,
            ),
            series: <ChartSeries>[
              ScatterSeries<CalibrationData, double>(
                dataSource: data,
                xValueMapper: (CalibrationData data, _) => data.predictedProbability,
                yValueMapper: (CalibrationData data, _) => data.actualFrequency,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  shape: DataMarkerType.circle,
                ),
              ),
              LineSeries<CalibrationData, double>(
                dataSource: [
                  CalibrationData(0, 0),
                  CalibrationData(1, 1),
                ],
                xValueMapper: (CalibrationData data, _) => data.predictedProbability,
                yValueMapper: (CalibrationData data, _) => data.actualFrequency,
                color: Colors.red,
                dashArray: [5, 5], // Dotted line style
              ),
            ],
          ),
          Text('Brier Score: ${brierScore.toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  List<CalibrationData> _calculateCalibrationData(List<Event> events) {
    final Map<double, List<bool>> groupedEvents = {};

    for (var event in events) {
      if (event.resolved != null) {
        groupedEvents.putIfAbsent(event.probability, () => []);
        groupedEvents[event.probability]!.add(event.resolved!);
      }
    }

    final List<CalibrationData> calibrationData = [];
    groupedEvents.forEach((probability, outcomes) {
      final frequency = outcomes.where((resolved) => resolved).length / outcomes.length;
      calibrationData.add(CalibrationData(probability, frequency));
    });

    return calibrationData;
  }

  double _calculateBrierScore(List<Event> events) {
    double brierScore = 0.0;
    int count = 0;

    for (var event in events) {
      if (event.resolved != null) {
        final outcome = event.resolved! ? 1.0 : 0.0;
        brierScore += (event.probability - outcome) * (event.probability - outcome);
        count++;
      }
    }

    return count > 0 ? brierScore / count : 0.0;
  }
}

class CalibrationData {
  final double predictedProbability;
  final double actualFrequency;

  CalibrationData(this.predictedProbability, this.actualFrequency);
}