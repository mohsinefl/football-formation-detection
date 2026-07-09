import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../painters/pitch_painter.dart';
import 'field_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiUrl = "https://football-formation-api.onrender.com";

  final apiController = TextEditingController(
    text: "https://football-formation-api.onrender.com",
  );

  final matchidController = TextEditingController(text: "DFL-MAT-J03YLO");
  final teamController = TextEditingController();

  final AudioPlayer player = AudioPlayer();
  final goalkeeperController = TextEditingController();

  String? selectedMatch;
  String? selectedTeam;
  String? lastFormation;

  Map<String, dynamic>? prediction;
  List<Map<String, dynamic>> history = [];

  Timer? liveTimer;

  bool liveRunning = false;
  bool loading = false;

  int selectedBottomTab = 0;

  bool showEllipses = true;
  bool showConvexHull = true;
  bool showCentroid = true;
  bool showLabels = true;

  double pitchLength = 105;
  double pitchWidth = 68;

  @override
  void initState() {
    super.initState();
    selectedMatch = matchidController.text.trim();
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    apiController.dispose();
    matchidController.dispose();
    teamController.dispose();
    player.dispose();
    super.dispose();
    goalkeeperController.dispose();
  }

  Future<void> loadLiveFormation() async {
    if (selectedMatch == null || selectedTeam == null) return;

    setState(() {
      loading = true;
    });

    final goalkeeperName = goalkeeperController.text.trim();

    final uri = Uri.parse("$apiUrl/formation/live").replace(
      queryParameters: {
        "match_id": selectedMatch!,
        "team_code": selectedTeam!,
        if (goalkeeperName.isNotEmpty) "goalkeeper_name": goalkeeperName,
      },
    );

    final response = await http.get(uri);

    final data = jsonDecode(response.body);

    if (data["message"] == "No more live data") {
      stopLive();
      return;
    }

    final minutes = data["loaded_minutes"];
    final newFormation = data["predicted_formation"];

    if (lastFormation != null && lastFormation != newFormation) {
      player.play(AssetSource("sounds/warning.mp3"));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Formation changed: $lastFormation → $newFormation"),
        ),
      );
    }

    lastFormation = newFormation;

    if (!mounted) return;

    setState(() {
      prediction = data;

      final alreadyExists = history.any(
        (item) => item["loaded_minutes"] == minutes,
      );

      if (!alreadyExists) {
        history.insert(0, data);
      }

      loading = false;
    });
  }

  void startLive() {
    selectedMatch = matchidController.text.trim();
    selectedTeam = teamController.text.trim().toUpperCase();

    if (selectedMatch == null ||
        selectedMatch!.isEmpty ||
        selectedTeam == null ||
        selectedTeam!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte Match ID und Team Code eingeben.")),
      );
      return;
    }

    liveTimer?.cancel();

    setState(() {
      liveRunning = true;
    });

    loadLiveFormation();

    liveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadLiveFormation(),
    );
  }

  void stopLive() {
    liveTimer?.cancel();

    setState(() {
      liveRunning = false;
      loading = false;
    });
  }

  Future<void> resetLive() async {
    stopLive();

    selectedMatch = matchidController.text.trim();
    selectedTeam = teamController.text.trim().toUpperCase();

    if (selectedMatch == null || selectedTeam == null) return;

    await http.get(
      Uri.parse(
        "$apiUrl/formation/reset?"
        "match_id=$selectedMatch"
        "&team_code=$selectedTeam",
      ),
    );

    setState(() {
      prediction = null;
      history.clear();
      lastFormation = null;
      liveRunning = false;
      loading = false;
    });
  }

  Widget _buildCurrentPage() {
    if (selectedBottomTab == 1) {
      return FieldPage(
        prediction: prediction,
        showEllipses: showEllipses,
        showConvexHull: showConvexHull,
        showCentroid: showCentroid,
        showLabels: showLabels,
        pitchLength: pitchLength,
        pitchWidth: pitchWidth,
      );
    }

    if (selectedBottomTab == 2) {
      return HistoryPage(history: history);
    }

    if (selectedBottomTab == 3) {
      return SettingsPage(
        apiController: apiController,
        onApiChanged: (value) {
          apiUrl = value.trim();
        },
        showEllipses: showEllipses,
        showConvexHull: showConvexHull,
        showCentroid: showCentroid,
        showLabels: showLabels,
        pitchLength: pitchLength,
        pitchWidth: pitchWidth,
        onShowEllipsesChanged: (value) {
          setState(() => showEllipses = value);
        },
        onShowConvexHullChanged: (value) {
          setState(() => showConvexHull = value);
        },
        onShowCentroidChanged: (value) {
          setState(() => showCentroid = value);
        },
        onShowLabelsChanged: (value) {
          setState(() => showLabels = value);
        },
        onPitchLengthChanged: (value) {
          setState(() => pitchLength = value);
        },
        onPitchWidthChanged: (value) {
          setState(() => pitchWidth = value);
        },
      );
    }

    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Match Setup",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: apiController,
                    decoration: const InputDecoration(
                      labelText: "API URL",
                      prefixIcon: Icon(Icons.cloud_outlined),
                    ),
                    onChanged: (value) {
                      apiUrl = value.trim();
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: matchidController,
                    decoration: const InputDecoration(
                      labelText: "Match ID",
                      prefixIcon: Icon(Icons.sports_soccer),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: teamController,
                    decoration: const InputDecoration(
                      labelText: "Team Code",
                      hintText: "WOB oder SVD",
                      prefixIcon: Icon(Icons.groups_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: goalkeeperController,
                    decoration: const InputDecoration(
                      labelText: "Goalkeeper Name optional",
                      hintText: "z.B. K. Casteels",
                      prefixIcon: Icon(Icons.sports_handball),
                    ),
                  ),

                  if (prediction?["matched_goalkeeper"] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Goalkeeper matched: ${prediction!["matched_goalkeeper"]}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: liveRunning ? null : startLive,
                          icon: const Icon(Icons.play_arrow),
                          label: const FittedBox(child: Text("Start")),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: liveRunning ? stopLive : null,
                          icon: const Icon(Icons.pause),
                          label: const FittedBox(child: Text("Stop")),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: resetLive,
                          icon: const Icon(Icons.refresh),
                          label: const FittedBox(child: Text("Reset")),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (loading) const CircularProgressIndicator(),

          const SizedBox(height: 10),

          _buildFormationCard(),
        ],
      ),
    );
  }

  Widget _buildFormationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Detected Formation",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              prediction?["predicted_formation"] ?? "-",
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Minute: ${prediction?["loaded_minutes"] ?? "-"}",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({required IconData icon, required int index}) {
    final bool isSelected = selectedBottomTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.white54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      "Live Control",
      "Tactical Field",
      "Formation History",
      "Settings",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedBottomTab]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  liveRunning
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: liveRunning ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  liveRunning ? "LIVE" : "OFFLINE",
                  style: TextStyle(
                    color: liveRunning ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: const Color(0xFF141A22),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF2A3441)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(icon: Icons.home_rounded, index: 0),
              _buildBottomNavItem(icon: Icons.stadium_rounded, index: 1),
              _buildBottomNavItem(icon: Icons.history_rounded, index: 2),
              _buildBottomNavItem(icon: Icons.settings_rounded, index: 3),
            ],
          ),
        ),
      ),
    );
  }
}
