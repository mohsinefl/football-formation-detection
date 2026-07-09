import 'package:flutter/material.dart';

import '../painters/pitch_painter.dart';

class FieldPage extends StatelessWidget {
  final Map<String, dynamic>? prediction;

  final bool showEllipses;
  final bool showConvexHull;
  final bool showCentroid;
  final bool showLabels;

  final double pitchLength;
  final double pitchWidth;

  const FieldPage({
    super.key,
    required this.prediction,
    required this.showEllipses,
    required this.showConvexHull,
    required this.showCentroid,
    required this.showLabels,
    required this.pitchLength,
    required this.pitchWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (prediction == null) {
      return const Center(
        child: Text(
          "Noch keine Formation erkannt.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Text(
                    "Detected Formation",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prediction?["predicted_formation"] ?? "-",
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Minute: ${prediction?["loaded_minutes"] ?? "-"}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (prediction?["players"] != null)
            SizedBox(
              width: double.infinity,
              height: 430,
              child: CustomPaint(
                painter: PitchPainter(
                  players: prediction!["players"],
                  showEllipses: showEllipses,
                  showConvexHull: showConvexHull,
                  showCentroid: showCentroid,
                  showLabels: showLabels,
                  pitchLength: pitchLength,
                  pitchWidth: pitchWidth,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
