import 'dart:convert';
import 'timestamp.dart';

class Record {
  int? id;
  String name;
  int? collectionId;
  int? episode;
  String? notes;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;
  List<Timestamp> timestamps;

  Record({
    this.id,
    required this.name,
    this.collectionId,
    this.episode,
    this.notes,
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    List<Timestamp>? timestamps,
  }) : dateCreated = dateCreated ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now(),
       timestamps = timestamps ?? [];

  void addTimestamp(Timestamp timestamp) {
    timestamps.add(timestamp);
    lastUpdated = DateTime.now();
  }

  void removeTimestamp(int index) {
    if (index >= 0 && index < timestamps.length) {
      timestamps.removeAt(index);
      lastUpdated = DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'collectionId': collectionId,
      'episode': episode,
      'notes': notes,
      'image': image,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'timestamps': jsonEncode(timestamps.map((t) => t.toMap()).toList()),
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    List<Timestamp> parsedTimestamps = [];

    if (map['timestamps'] != null &&
        map['timestamps'] is String &&
        map['timestamps'].toString().isNotEmpty) {
      try {
        final List<dynamic> rawList = jsonDecode(map['timestamps']);
        parsedTimestamps =
            rawList.map((json) => Timestamp.fromMap(json)).toList();
      } catch (e) {
        print("Failed to decode timestamps: $e");
      }
    }

    return Record(
      id: map['id'],
      name: map['name'] ?? 'Untitled',
      collectionId: map['collectionId'],
      episode: map['episode'],
      notes: map['notes'] ?? '',
      image: map['image'] ?? '',
      dateCreated:
          DateTime.tryParse(map['dateCreated'] ?? '') ?? DateTime.now(),
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      timestamps: parsedTimestamps,
    );
  }

  Record copyWith({
    String? name,
    int? episode,
    String? notes,
    Object? collectionId = _sentinel, // use Object to allow null explicitly
    String? image,
    DateTime? lastUpdated,
    List<Timestamp>? timestamps,
  }) {
    return Record(
      id: id,
      name: name ?? this.name,
      episode: episode ?? this.episode,
      notes: notes ?? this.notes,
      collectionId:
          collectionId == _sentinel ? this.collectionId : collectionId as int?,
      image: image ?? this.image,
      dateCreated: this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  static const _sentinel = Object();
}
