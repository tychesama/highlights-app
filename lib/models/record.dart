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
  int duration; // in seconds
  bool isFavorite;
  DateTime? lastAccessed;
  bool isHidden;
  bool isDeleted;
  String? colorHex;
  double playbackSpeed;

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
    this.duration = 0,
    this.isFavorite = false,
    this.lastAccessed,
    this.isHidden = false,
    this.isDeleted = false,
    this.colorHex,
    this.playbackSpeed = 1.0,
  })  : dateCreated = dateCreated ?? DateTime.now(),
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
      'duration': duration,
      'isFavorite': isFavorite ? 1 : 0,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'isHidden': isHidden ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'colorHex': colorHex,
      'playbackSpeed': playbackSpeed,
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
      timestamps: (jsonDecode(map['timestamps']) as List<dynamic>)
          .map((json) => Timestamp.fromMap(json))
          .toList(),
      duration: map['duration'] ?? 0,
      isFavorite: map['isFavorite'] == 1,
      lastAccessed: map['lastAccessed'] != null
          ? DateTime.parse(map['lastAccessed'])
          : null,
      isHidden: map['isHidden'] == 1,
      isDeleted: map['isDeleted'] == 1,
      colorHex: map['colorHex'],
      playbackSpeed: (map['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Record copyWith({
    String? name,
    int? episode,
    String? notes,
    int? collectionId,
    String? image,
    DateTime? lastUpdated,
    List<Timestamp>? timestamps,
    int? duration,
    bool? isFavorite,
    DateTime? lastAccessed,
    bool? isHidden,
    bool? isDeleted,
    String? colorHex,
    double? playbackSpeed,
  }) {
    return Record(
      id: id,
      name: name ?? this.name,
      episode: episode ?? this.episode,
      notes: notes ?? this.notes,
      collectionId: collectionId ?? this.collectionId,
      image: image ?? this.image,
      dateCreated: this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      timestamps: timestamps ?? this.timestamps,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isHidden: isHidden ?? this.isHidden,
      isDeleted: isDeleted ?? this.isDeleted,
      colorHex: colorHex ?? this.colorHex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}
