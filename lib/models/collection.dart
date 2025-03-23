import 'dart:convert';

class Collection {
  int? id;
  String name;
  String? type;
  int? season;
  String? description;
  DateTime dateCreated;
  DateTime lastUpdated;
  String? thumbnail;
  int totalRecords;
  bool isFavorite;
  String? status;
  DateTime? lastAccessed;
  bool isHidden;
  bool isDeleted;
  String? colorHex;

  Collection({
    this.id,
    required this.name,
    this.type,
    this.season,
    this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    this.thumbnail,
    this.totalRecords = 0,
    this.isFavorite = false,
    this.status,
    this.lastAccessed,
    this.isHidden = false,
    this.isDeleted = false,
    this.colorHex,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'season': season,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'thumbnail': thumbnail,
      'totalRecords': totalRecords,
      'isFavorite': isFavorite ? 1 : 0,
      'status': status,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'isHidden': isHidden ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'colorHex': colorHex,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      season: map['season'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      thumbnail: map['thumbnail'],
      totalRecords: map['totalRecords'] ?? 0,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      status: map['status'],
      lastAccessed: map['lastAccessed'] != null
          ? DateTime.parse(map['lastAccessed'])
          : null,
      isHidden: (map['isHidden'] ?? 0) == 1,
      isDeleted: (map['isDeleted'] ?? 0) == 1,
      colorHex: map['colorHex'],
    );
  }

  Collection copyWith({
    int? id,
    String? name,
    String? description,
    int? season,
    String? type,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    String? thumbnail,
    int? totalRecords,
    bool? isFavorite,
    String? status,
    DateTime? lastAccessed,
    bool? isHidden,
    bool? isDeleted,
    String? colorHex,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      season: season ?? this.season,
      type: type ?? this.type,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      thumbnail: thumbnail ?? this.thumbnail,
      totalRecords: totalRecords ?? this.totalRecords,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isHidden: isHidden ?? this.isHidden,
      isDeleted: isDeleted ?? this.isDeleted,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
