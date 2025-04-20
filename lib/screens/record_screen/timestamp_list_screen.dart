import 'package:flutter/material.dart';
import '../../models/record.dart';
import '../../models/timestamp.dart';
import '../../providers/record_provider.dart';
import 'package:provider/provider.dart';

class TimestampListScreen extends StatefulWidget {
  final Record record;

  const TimestampListScreen({super.key, required this.record});

  @override
  State<TimestampListScreen> createState() => _TimestampListScreenState();
}

class _TimestampListScreenState extends State<TimestampListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RecordProvider>(context, listen: false)
          .loadTimestampsForRecord(widget.record);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, recordProvider, child) {
        final timestamps = recordProvider.getTimestampsForRecord(widget.record.id!);
        final int maxTime = timestamps.isNotEmpty
            ? timestamps.map((t) => t.endTime ?? t.time).reduce((a, b) => a > b ? a : b)
            : 1;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // Removed the rounded corners and kept it rectangular
            borderRadius: BorderRadius.zero, // No rounded corners
            border: Border.all(color: Colors.white30, width: 1.5),
            color: Theme.of(context).scaffoldBackgroundColor, // Dark background for contrast
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timestamps', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),

              // Timeline
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Base line for timeline
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 4,
                              width: constraints.maxWidth,
                              color: Colors.white24, // Lighter color for the base line
                            ),
                          ),
                        ),

                        // Markers or durations on the timeline
                        ...timestamps.map((timestamp) {
                          final double start = (timestamp.time / maxTime) * constraints.maxWidth;
                          final double? end = timestamp.endTime != null
                              ? (timestamp.endTime! / maxTime) * constraints.maxWidth
                              : null;

                          if (end != null) {
                            return Positioned(
                              left: start,
                              top: 22,
                              child: Container(
                                height: 8,
                                width: end - start,
                                color: Colors.orange.withOpacity(0.8),
                              ),
                            );
                          } else {
                            return Positioned(
                              left: start,
                              top: 20,
                              child: Column(
                                children: [
                                  const Icon(Icons.circle, size: 10, color: Colors.orange),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTime(timestamp.time),
                                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                              ),
                            );
                          }
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // List of timestamps
              Expanded(
                child: timestamps.isEmpty
                    ? const Center(child: Text('No timestamps yet.', style: TextStyle(color: Colors.white60)))
                    : ListView.builder(
                        itemCount: timestamps.length,
                        itemBuilder: (context, index) {
                          final timestamp = timestamps[index];
                          final isDuration = timestamp.endTime != null;
                          final displayTime = isDuration
                              ? "${formatTime(timestamp.time)} → ${formatTime(timestamp.endTime!)}"
                              : formatTime(timestamp.time);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.access_time, color: Colors.orange),
                            title: Text(displayTime, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              timestamp.description.isNotEmpty
                                  ? timestamp.description
                                  : 'No description',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: timestamp.image != null
                                ? Image.network(
                                    timestamp.image!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
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
