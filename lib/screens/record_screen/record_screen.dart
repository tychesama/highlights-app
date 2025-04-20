import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/record_provider.dart';
import '../../models/record.dart';

class RecordScreen extends StatefulWidget {
  final Record record;

  const RecordScreen({super.key, required this.record});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  String formatTime(int milliseconds) {
    int ms = milliseconds % 1000;
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000) % 60;
    int hours = milliseconds ~/ 3600000;
    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}."
        "${ms.toString().padLeft(3, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final recordProvider = Provider.of<RecordProvider>(context);
    final isPlaying = recordProvider.isPlaying;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 350,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.white30, width: 1.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isPlaying)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //removed the visual "recording..."
                ],
              ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                if (isPlaying) {
                  recordProvider.addTimestampToRecord(widget.record);
                }
              },
              child: Container(
                width: screenWidth * 0.45,
                height: screenWidth * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Mark',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              formatTime(
                recordProvider.getElapsedMillisecondsForRecord(
                  widget.record.id!,
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Play',
                  color: Colors.green,
                  onPressed: () {
                    if (!recordProvider.isPlaying) {
                      recordProvider.togglePlay();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  tooltip: 'Pause',
                  color: Colors.amber,
                  onPressed: () {
                    if (recordProvider.isPlaying) {
                      recordProvider.togglePlay();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                  color: Colors.red,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward),
                  tooltip: 'Fast Forward',
                  color: Colors.blue,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  color: Colors.purple,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'More',
                  color: Colors.grey,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
