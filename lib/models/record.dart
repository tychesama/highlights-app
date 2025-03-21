import 'dart:convert';
import 'collection.dart';

class Record {
  int? id;
  String name;
  Collection collection;
  int episode;
  String? notes;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;
  List<Map<String, dynamic>> _timestamps;

  Record({
    this.id,
    required this.name,
    required this.collection,
    required this.episode,
    this.notes,
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    List<Map<String, dynamic>>? timestamps,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        _timestamps = timestamps ?? [];

  // Public getter for timestamps
  List<Map<String, dynamic>> get timestamps => _timestamps;

  void addTimestamp(int time, {String description = ""}) {
    _timestamps.add({"time": time, "description": description});
  }

  void removeTimestamp(int index) {
    if (index >= 0 && index < _timestamps.length) {
      _timestamps.removeAt(index);
    }
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'collection': jsonEncode(collection.toMap()), // Store collection as JSON
      'episode': episode,
      'notes': notes,
      'image': image,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'timestamps': jsonEncode(_timestamps), // Store timestamps as JSON
    };
  }

  // Convert from Map
  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      collection: Collection.fromMap(jsonDecode(map['collection'])), // Convert JSON back to Collection
      episode: map['episode'],
      notes: map['notes'],
      image: map['image'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      timestamps: List<Map<String, dynamic>>.from(jsonDecode(map['timestamps'])),
    );
  }
}
