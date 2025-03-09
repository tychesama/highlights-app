import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/type.dart';

class RecordProvider extends ChangeNotifier {
  final List<Record> _records = [];
  bool _isPlaying = false;
  final Stopwatch _stopwatch = Stopwatch();

  List<Record> get records => _records;
  bool get isPlaying => _isPlaying;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void addRecord(Record record) {
    _records.add(record);
    notifyListeners();
  }

  void addTimestampToRecord(Record record, {String? description}) {
    record.addTimestamp(_stopwatch.elapsedMilliseconds, description: description ?? "");
    notifyListeners();
  }

  void removeTimestampFromRecord(Record record, int index) {
    record.removeTimestamp(index);
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void resetTimerForRecord(Record record) {
    _stopwatch.reset();
    record.timestamps.clear();
    _isPlaying = false;
    notifyListeners();
  }
}
