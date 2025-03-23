import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/collection.dart';
import 'record_info_screen.dart';
import 'record_screen.dart';
import 'timestamp_list_screen.dart';

class MainRecordScreen extends StatefulWidget {
  final Record record;
  final Collection? collection;

  const MainRecordScreen({super.key, required this.record, this.collection});

  @override
  State<MainRecordScreen> createState() => _MainRecordScreenState();
}

class _MainRecordScreenState extends State<MainRecordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final double recordScreenHeight = 175;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleRecordScreen() {
    if (_controller.isCompleted) {
      _controller.reverse(); // Hide RecordScreen
    } else {
      _controller.forward(); // Show RecordScreen
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record"),
        actions: [
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
            ),
            onPressed: _toggleRecordScreen,
            tooltip: "Toggle Record View",
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final recordOffset = -_animation.value * recordScreenHeight;
          final timestampOffset = _animation.value * recordScreenHeight;

          return Stack(
            children: [
              /// Slides up to hide
              Positioned(
                top: recordOffset,
                left: 0,
                right: 0,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: RecordInfoScreen(
                    record: widget.record,
                    collection: widget.collection,
                  ),
                ),
              ),

              /// Slides down into place
              Positioned(
                top: recordOffset + recordScreenHeight,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: RecordScreen(record: widget.record),
                ),
              ),

              /// Stays visible, gets pushed down
              Positioned(
                top: recordScreenHeight + timestampOffset,
                left: 0,
                right: 0,
                bottom: 0,
                child: TimestampListScreen(record: widget.record),
              ),
            ],
          );
        },
      ),
    );
  }
}
