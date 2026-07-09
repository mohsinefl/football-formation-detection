import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController apiController;
  final ValueChanged<String> onApiChanged;

  final bool showEllipses;
  final bool showConvexHull;
  final bool showCentroid;
  final bool showLabels;

  final double pitchLength;
  final double pitchWidth;

  final ValueChanged<bool> onShowEllipsesChanged;
  final ValueChanged<bool> onShowConvexHullChanged;
  final ValueChanged<bool> onShowCentroidChanged;
  final ValueChanged<bool> onShowLabelsChanged;

  final ValueChanged<double> onPitchLengthChanged;
  final ValueChanged<double> onPitchWidthChanged;

  const SettingsPage({
    super.key,
    required this.apiController,
    required this.onApiChanged,
    required this.showEllipses,
    required this.showConvexHull,
    required this.showCentroid,
    required this.showLabels,
    required this.pitchLength,
    required this.pitchWidth,
    required this.onShowEllipsesChanged,
    required this.onShowConvexHullChanged,
    required this.onShowCentroidChanged,
    required this.onShowLabelsChanged,
    required this.onPitchLengthChanged,
    required this.onPitchWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "App Settings",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Player Ellipses"),
                  subtitle: const Text("Positionsstreuung anzeigen"),
                  value: showEllipses,
                  onChanged: onShowEllipsesChanged,
                  secondary: const Icon(Icons.blur_on),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Convex Hull"),
                  subtitle: const Text("Teamfläche anzeigen"),
                  value: showConvexHull,
                  onChanged: onShowConvexHullChanged,
                  secondary: const Icon(Icons.timeline),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Centroid"),
                  subtitle: const Text("Zentrum der Formation anzeigen"),
                  value: showCentroid,
                  onChanged: onShowCentroidChanged,
                  secondary: const Icon(Icons.add_location_alt_outlined),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Player Labels"),
                  subtitle: const Text("Spielernamen anzeigen"),
                  value: showLabels,
                  onChanged: onShowLabelsChanged,
                  secondary: const Icon(Icons.label_outline),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pitch Dimensions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Text("Pitch Length: ${pitchLength.toStringAsFixed(0)} m"),
                  Slider(
                    value: pitchLength,
                    min: 90,
                    max: 120,
                    divisions: 30,
                    label: pitchLength.toStringAsFixed(0),
                    onChanged: onPitchLengthChanged,
                  ),

                  const SizedBox(height: 12),

                  Text("Pitch Width: ${pitchWidth.toStringAsFixed(0)} m"),
                  Slider(
                    value: pitchWidth,
                    min: 55,
                    max: 80,
                    divisions: 25,
                    label: pitchWidth.toStringAsFixed(0),
                    onChanged: onPitchWidthChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
