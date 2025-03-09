import 'dart:async';
import 'package:flutter/material.dart';

class RecordProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _timestamps = [];
  bool _isPlaying = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  List<Map<String, dynamic>> get timestamps => _timestamps;
  bool get isPlaying => _isPlaying;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void togglePlay() {
    if (_isPlaying) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        notifyListeners(); // Update UI every 10ms
      });
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void addTimestamp({String? description}) {
    _timestamps.add({
      "time": _stopwatch.elapsedMilliseconds,
      "description": description ?? "",
    });
    notifyListeners();
  }

  void removeTimestamp(int index) {
    if (index >= 0 && index < _timestamps.length) {
      _timestamps.removeAt(index);
      notifyListeners();
    }
  }

  void resetTimer() {
    _stopwatch.reset();
    _timestamps.clear();
    _isPlaying = false;
    notifyListeners();
  }
}
