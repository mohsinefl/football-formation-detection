import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          "Noch kein Verlauf vorhanden.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        return Card(
          child: ListTile(
            title: Text(
              item["predicted_formation"] ?? "No prediction",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Minute: ${item["loaded_minutes"] ?? "-"}"),
            trailing: Text("${item["total_rows"] ?? "-"} rows"),
          ),
        );
      },
    );
  }
}
