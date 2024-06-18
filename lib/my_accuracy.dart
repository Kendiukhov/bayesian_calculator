import 'package:flutter/material.dart';
import 'calibration_curve.dart';
import 'models/event.dart';

class MyAccuracy extends StatelessWidget {
  final List<Event> events;

  const MyAccuracy({required this.events, super.key});

  double calculateBrierScore(List<Event> events) {
    double sumSquaredErrors = 0;
    int count = 0;

    for (var event in events) {
      if (event.resolved != null) {
        double forecastProbability = event.probability;
        int actualOutcome = event.resolved! ? 1 : 0;
        sumSquaredErrors += (forecastProbability - actualOutcome) * (forecastProbability - actualOutcome);
        count++;
      }
    }

    return count > 0 ? sumSquaredErrors / count : 0;
  }

  @override
  Widget build(BuildContext context) {
    double brierScore = calculateBrierScore(events.where((e) => e.resolved != null).toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accuracy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalibrationCurve(events: events.where((e) => e.resolved != null).toList()),
            const SizedBox(height: 20),
            const Text(
              'Calibration Curve',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'The calibration curve shows how well your predicted probabilities match the actual outcomes. '
                  'If your predictions are perfectly calibrated, the points should lie on the diagonal line.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Brier Score',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'The Brier Score measures the accuracy of your probabilistic predictions. '
                  'It ranges from 0 to 1, where 0 indicates perfect accuracy and 1 indicates the worst accuracy.',
            ),
            const SizedBox(height: 10),
            Text(
              'Your Brier Score: ${brierScore.toStringAsFixed(3)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}