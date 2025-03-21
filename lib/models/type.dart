
import 'dart:convert';

abstract class Type {
  final String name;
  DateTime dateCreated;
  DateTime lastUpdated;

  Type({
    required this.name,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  // Convert to Map
  Map<String, dynamic> toMap();

  // Convert from Map (Factory Constructor)
  static Type fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'Series':
        return Series.fromMap(map);
      case 'Movie':
        return Movie.fromMap(map);
      case 'Anime':
        return Anime.fromMap(map);
      case 'Stream':
        return Stream.fromMap(map);
      default:
        return Others.fromMap(map);
    }
  }
}


/// Series Type
class Series extends Type {
  String title;
  int season;
  int episode;
  String description;

  Series({
    required this.title,
    required this.season,
    required this.episode,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'Series',
      'title': title,
      'season': season,
      'episode': episode,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Series.fromMap(Map<String, dynamic> map) {
    return Series(
      title: map['title'],
      season: map['season'],
      episode: map['episode'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
