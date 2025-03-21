import 'dart:convert';

class Collection {
  int? id;
  String name;
  String type;
  int? season;
  String? description;
  DateTime dateCreated;
  DateTime lastUpdated;

  Collection({
    this.id,
    required this.name,
    required this.type,
    this.season,
    this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'season': season,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Convert from Map
  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      season: map['season'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
