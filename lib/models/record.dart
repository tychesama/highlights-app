import 'dart:convert';

class Record {
  int? id;
  String name;
  int? collectionId;
  int? episode;
  String? notes;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;
  List<Map<String, dynamic>> _timestamps;

  Record({
    this.id,
    required this.name,
    this.collectionId,
    this.episode,
    this.notes,
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    List<Map<String, dynamic>>? timestamps,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        _timestamps = timestamps ?? [];

  List<Map<String, dynamic>> get timestamps => _timestamps;

  void addTimestamp(int time, {String description = ""}) {
    _timestamps.add({"time": time, "description": description});
  }

  void removeTimestamp(int index) {
    if (index >= 0 && index < _timestamps.length) {
      _timestamps.removeAt(index);
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
      'timestamps': jsonEncode(_timestamps),
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      name: map['name'],
      collectionId: map['collectionId'],
      episode: map['episode'],
      notes: map['notes'],
      image: map['image'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      timestamps: List<Map<String, dynamic>>.from(jsonDecode(map['timestamps'])),
    );
  }

  Record copyWith({
    String? name,
    int? episode,
    String? notes,
    int? collectionId,
    DateTime? lastUpdated,
  }) {
    return Record(
      id: this.id,
      name: name ?? this.name,
      episode: episode ?? this.episode,
      notes: notes ?? this.notes,
      collectionId: collectionId ?? this.collectionId,
      dateCreated: this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      timestamps: this.timestamps,
    );
  }

}
