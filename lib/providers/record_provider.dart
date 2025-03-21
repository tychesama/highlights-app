import 'package:flutter/material.dart';
import '../models/record.dart';
import 'dart:async';
import '../services/database_helper.dart';

class RecordProvider extends ChangeNotifier {
  List<Record> _records = [];
  bool _isPlaying = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  RecordProvider() {
    fetchRecords(); // Load records on startup
  }

  List<Record> get records => _records;

  Future<void> fetchRecords() async {
    _records = await DatabaseHelper.instance.getAllRecords(); // Fetch all records
    notifyListeners();
  }

  Future<void> addRecord(Record record) async {
    await DatabaseHelper.instance.insertRecord(record);
    await fetchRecords(); // Refresh all records
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteRecord(id);
    await fetchRecords(); // Refresh all records
  }

  bool get isPlaying => _isPlaying;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void addRecordLocal(Record record) {
    _records.add(record);
    notifyListeners();
  }

  void addTimestampToRecord(Record record, {String? description}) {
    record.addTimestamp(
      _stopwatch.elapsedMilliseconds,
      description: description ?? "",
    );
    notifyListeners();
  }

  void removeTimestampFromRecord(Record record, int index) {
    record.removeTimestamp(index);
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        notifyListeners();
      });
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
