import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/timestamp.dart';
import 'dart:async';
import '../services/database_helper.dart';
import 'package:provider/provider.dart';
import 'collection_provider.dart';
import '../services/navigation_service.dart';

class RecordProvider extends ChangeNotifier {
  List<Record> _records = [];
  bool _isPlaying = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // For duration timestamps
  int? _heldStartTime;

  RecordProvider() {
    fetchRecords();
  }

  String _searchQuery = '';

  List<Record> get filteredRecords {
    if (_searchQuery.isEmpty) return _records;
    return _records
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Record> get records => _records;

  Future<void> fetchRecords() async {
    _records = await DatabaseHelper.instance.getAllRecords();
    notifyListeners();
  }

  void updateRecord(Record updatedRecord) {
    final index = _records.indexWhere(
      (record) => record.id == updatedRecord.id,
    );
    if (index != -1) {
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  Future<void> addRecord(Record record) async {
    await DatabaseHelper.instance.insertRecord(record);
    await fetchRecords();

    await Future.delayed(Duration(milliseconds: 100));

    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      final collectionProvider = Provider.of<CollectionProvider>(
        context,
        listen: false,
      );
      await collectionProvider.fetchCollections();
      collectionProvider.updateCollectionLastUpdated(
        record.collectionId!,
        DateTime.now(),
      );
    }
  }

  Future<void> deleteRecord(Record record) async {
    await DatabaseHelper.instance.deleteRecord(record.id!);
    await fetchRecords();
  }

  Future<void> clearAllRecords() async {
    await DatabaseHelper.instance.clearAllRecords();
    _records.clear();
    notifyListeners();
  }

  List<Record> getAllRecords() => List.unmodifiable(_records);

  bool get isPlaying => _isPlaying;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void addRecordLocal(Record record) {
    _records.add(record);
    notifyListeners();
  }

  List<Timestamp> getTimestampsForRecord(int recordId) {
    final record = records.firstWhere(
      (r) => r.id == recordId,
      orElse:
          () => Record(
            id: -1,
            name: '',
            timestamps: [],
            dateCreated: DateTime.now(),
            lastUpdated: DateTime.now(),
          ),
    );
    return record.timestamps;
  }

  Future<void> loadTimestampsForRecord(Record record) async {
    final timestamps = await DatabaseHelper.instance.getTimestampsByRecordId(
      record.id!,
    );
    record.timestamps = timestamps;
    notifyListeners();
  }

  // Single timestamp (point-in-time)
  Future<void> addTimestampToRecord(
    Record record, {
    String? description,
  }) async {
    final timestamp = Timestamp(
      id: null, // Will be set by SQLite
      recordId: record.id!,
      time: _stopwatch.elapsedMilliseconds,
      description: description ?? "",
      dateCreated: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    // Save to database
    final insertedId = await DatabaseHelper.instance.insertTimestamp(timestamp);
    final savedTimestamp = timestamp.copyWith(id: insertedId); // assign the id

    // Add to the record
    record.addTimestamp(savedTimestamp);
    notifyListeners();
  }

  // Duration start
  void startHeldTimestamp() {
    _heldStartTime = _stopwatch.elapsedMilliseconds;
  }

  // Duration end and save
  Future<void> endHeldTimestamp(Record record, {String? description}) async {
    if (_heldStartTime != null) {
      final timestamp = Timestamp(
        id: null,
        recordId: record.id!,
        time: _heldStartTime!,
        endTime: _stopwatch.elapsedMilliseconds,
        description: description ?? "",
        dateCreated: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final id = await DatabaseHelper.instance.insertTimestamp(timestamp);
      final savedTimestamp = timestamp.copyWith(id: id);

      record.addTimestamp(savedTimestamp);
      _heldStartTime = null;
      notifyListeners();
    }
  }

  Future<void> removeTimestampFromRecord(Record record, int index) async {
    final timestamp = record.timestamps[index];
    await DatabaseHelper.instance.deleteTimestamp(timestamp.id!);

    record.removeTimestamp(index);
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        notifyListeners();
      });
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> updateTimestamp(Timestamp updatedTimestamp) async {
    await DatabaseHelper.instance.updateTimestamp(updatedTimestamp);

    // Update in-memory record
    final record = _records.firstWhere(
      (r) => r.id == updatedTimestamp.recordId,
    );
    final index = record.timestamps.indexWhere(
      (t) => t.id == updatedTimestamp.id,
    );
    if (index != -1) {
      record.timestamps[index] = updatedTimestamp;
      notifyListeners();
    }
  }

  Future<void> deleteTimestamp(Record record, int timestampId) async {
    await DatabaseHelper.instance.deleteTimestamp(timestampId);

    // Remove from in-memory record
    record.timestamps.removeWhere((t) => t.id == timestampId);
    notifyListeners();
  }

  void resetTimerForRecord(Record record) {
    _stopwatch.reset();
    record.timestamps.clear();
    _isPlaying = false;
    notifyListeners();
  }
}
