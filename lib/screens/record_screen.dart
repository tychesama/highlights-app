import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/record_provider.dart';
import '../models/record.dart';
import 'dart:async';

class RecordScreen extends StatefulWidget {
  final Record record;

  RecordScreen({required this.record});

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late Timer _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('assets/button_click.mp3'));
  }

  void _showTimestampSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16.0),
          child: Consumer<RecordProvider>(
            builder: (context, recordProvider, child) {
              return ListView.builder(
                itemCount: widget.record.timestamps.length,
                itemBuilder: (context, index) {
                  final timestamp = widget.record.timestamps[index];
                  return ListTile(
                    title: Text(formatTime(timestamp['time'])),
                    subtitle: Text(timestamp['description'] ?? ''),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordProvider = Provider.of<RecordProvider>(context);
    final timestamps = widget.record.timestamps;

    return Scaffold(
      appBar: AppBar(title: Text(widget.record.name)),
      body: Column(
        children: [
          Spacer(),
          GestureDetector(
            onTap: () {
              _playSound();
              if (recordProvider.isPlaying) {
                recordProvider.addTimestampToRecord(widget.record);
              }
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  'Mark',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            formatTime(recordProvider.elapsedMilliseconds),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onVerticalDragStart: (_) => _showTimestampSheet(context),
            child: Container(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: TimelinePainter(timestamps, recordProvider.elapsedMilliseconds),
              ),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: recordProvider.togglePlay,
                child: Text(recordProvider.isPlaying ? 'Pause' : 'Play'),
              ),
              ElevatedButton(
                onPressed: () => recordProvider.resetTimerForRecord(widget.record),
                child: Text('Reset'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  String formatTime(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000) % 60;
    int hours = milliseconds ~/ 3600000;
    return "${hours.toString().padLeft(2, '0')}:" 
           "${minutes.toString().padLeft(2, '0')}:" 
           "${seconds.toString().padLeft(2, '0')}";
  }
}

class TimelinePainter extends CustomPainter {
  final List<Map<String, dynamic>> timestamps;
  final int elapsedMilliseconds;

  TimelinePainter(this.timestamps, this.elapsedMilliseconds);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0;

    final Paint markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    double maxTime = elapsedMilliseconds > 0 ? elapsedMilliseconds.toDouble() : 1;
    double scaleFactor = size.width / maxTime;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);

    for (var timestamp in timestamps) {
      double markX = timestamp['time'] * scaleFactor;
      canvas.drawCircle(Offset(markX, size.height / 2), 6, markerPaint);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.elapsedMilliseconds != elapsedMilliseconds ||
           oldDelegate.timestamps != timestamps;
  }
}
