import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';

class RecordScreen extends StatelessWidget {
  final String title;

  RecordScreen({required this.title}); // Accept title

  @override
  Widget build(BuildContext context) {
    final recordProvider = Provider.of<RecordProvider>(context);

    String formatTime(int milliseconds) {
      int ms = milliseconds % 1000;
      int seconds = (milliseconds ~/ 1000) % 60;
      int minutes = (milliseconds ~/ 60000) % 60;
      int hours = milliseconds ~/ 3600000;

      return "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}:"
            "${ms.toString().padLeft(3, '0')}";
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Elapsed Time: ${formatTime(recordProvider.elapsedMilliseconds)}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recordProvider.timestamps.length,
              itemBuilder: (context, index) {
                final timestamp = recordProvider.timestamps[index];
                return ListTile(
                  title: Text("Time: ${formatTime(timestamp['time'])}"),
                  subtitle: Text("Note: ${timestamp['description']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => recordProvider.removeTimestamp(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: recordProvider.isPlaying ? recordProvider.addTimestamp : null,
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60)),
                  child: Text('Mark Timestamp', style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: recordProvider.togglePlay,
                  child: Text(recordProvider.isPlaying ? 'Pause' : 'Play'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: recordProvider.resetTimer,
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
