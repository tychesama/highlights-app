import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/timestamp.dart';
import 'dart:async';
import '../services/database_helper.dart';
import 'package:provider/provider.dart';
import 'collection_provider.dart';
import '../services/navigation_service.dart';

class RecordProvider extends ChangeNotifier {
  // --------------------------------------------------
  // Records
  // --------------------------------------------------

  List<Record> _records = [];
  String _searchQuery = '';

  List<Record> get records => _records;

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

  Future<void> fetchRecords() async {
    _records = await DatabaseHelper.instance.getAllRecords();
    notifyListeners();
  }

  Future<Record?> getRecordById(int id) async {
    return await DatabaseHelper.instance.getRecordById(id);
  }

  Future<void> updateRecord(Record updatedRecord) async {
    final index = _records.indexWhere((record) => record.id == updatedRecord.id);
    if (index != -1) {
      await DatabaseHelper.instance.updateRecord(updatedRecord);
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  Future<int> addRecord(Record record) async {
    final newId = await DatabaseHelper.instance.insertRecord(record);
    await fetchRecords();
    await Future.delayed(Duration(milliseconds: 100));

    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
      await collectionProvider.fetchCollections();
      if (record.collectionId != null) {
        collectionProvider.updateCollectionLastUpdated(record.collectionId!, DateTime.now());
      }
    }

    return newId;
  }

  Future<void> deleteRecord(Record record) async {
    await DatabaseHelper.instance.deleteRecord(record.id!);
    _initialOffsets.remove(record.id); // Clear offset
    await fetchRecords();
  }

  Future<void> clearAllRecords() async {
    await DatabaseHelper.instance.clearAllRecords();
    _records.clear();
    _initialOffsets.clear();
    notifyListeners();
  }

  List<Record> getAllRecords() => List.unmodifiable(_records);

  // --------------------------------------------------
  // Stopwatch
  // --------------------------------------------------

  bool _isPlaying = false;
  Stopwatch _stopwatch = Stopwatch();
  bool get isPlaying => _isPlaying;

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
    _initialOffsets[record.id!] = Duration.zero;
    record.timestamps.clear();
    _isPlaying = false;
    notifyListeners();
  }

  // --------------------------------------------------
  // Timer Offsets
  // --------------------------------------------------

  final Map<int, Duration> _initialOffsets = {};

  int getElapsedMillisecondsForRecord(int recordId) {
    final offset = _initialOffsets[recordId] ?? Duration.zero;
    return offset.inMilliseconds + _stopwatch.elapsedMilliseconds;
  }

  void setElapsedMillisecondsForRecord(int recordId, int value) {
    _initialOffsets[recordId] = Duration(milliseconds: value);
    notifyListeners();
  }

  // --------------------------------------------------
  // Timestamps
  // --------------------------------------------------

  int? _heldStartTime;

  List<Timestamp> getTimestampsForRecord(int recordId) {
    final record = records.firstWhere(
      (r) => r.id == recordId,
      orElse: () => Record(
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
    final timestamps = await DatabaseHelper.instance.getTimestampsByRecordId(record.id!);
    record.timestamps = timestamps;

    if (timestamps.isNotEmpty) {
      final latest = timestamps.map((t) => t.endTime ?? t.time).reduce((a, b) => a > b ? a : b);
      _initialOffsets[record.id!] = Duration(milliseconds: latest);
    } else {
      _initialOffsets[record.id!] = Duration.zero;
    }

    notifyListeners();
  }

  Future<void> addTimestampToRecord(
    Record record, {
    String? description,
  }) async {
    final currentTime = getElapsedMillisecondsForRecord(record.id!);

    final timestamp = Timestamp(
      id: null,
      recordId: record.id!,
      time: currentTime,
      description: description ?? "",
      dateCreated: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    final insertedId = await DatabaseHelper.instance.insertTimestamp(timestamp);
    final savedTimestamp = timestamp.copyWith(id: insertedId);

    record.addTimestamp(savedTimestamp);
    notifyListeners();
  }

  void startHeldTimestamp(Record record) {
    _heldStartTime = getElapsedMillisecondsForRecord(record.id!);
  }

  Future<void> endHeldTimestamp(Record record, {String? description}) async {
    if (_heldStartTime != null) {
      final currentTime = getElapsedMillisecondsForRecord(record.id!);

      final timestamp = Timestamp(
        id: null,
        recordId: record.id!,
        time: _heldStartTime!,
        endTime: currentTime,
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

  Future<void> updateTimestamp(Timestamp updatedTimestamp) async {
    await DatabaseHelper.instance.updateTimestamp(updatedTimestamp);
    final record = _records.firstWhere((r) => r.id == updatedTimestamp.recordId);
    final index = record.timestamps.indexWhere((t) => t.id == updatedTimestamp.id);
    if (index != -1) {
      record.timestamps[index] = updatedTimestamp;
      notifyListeners();
    }
  }

  Future<void> deleteTimestamp(Record record, int timestampId) async {
    await DatabaseHelper.instance.deleteTimestamp(timestampId);
    record.timestamps.removeWhere((t) => t.id == timestampId);
    notifyListeners();
  }

  Future<void> removeTimestampFromRecord(Record record, int index) async {
    final timestamp = record.timestamps[index];
    await DatabaseHelper.instance.deleteTimestamp(timestamp.id!);
    record.removeTimestamp(index);
    notifyListeners();
  }
}
