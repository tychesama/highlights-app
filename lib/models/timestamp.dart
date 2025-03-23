class Timestamp {
  int? id;
  int recordId;
  int time; // start time in milliseconds
  int? endTime; // optional end time
  String description;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;
  List<String> tags;
  bool isDeleted;
  bool isFavorite;
  String? category;
  String? color;

  Timestamp({
    this.id,
    required this.recordId,
    required this.time,
    this.endTime,
    this.description = '',
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    List<String>? tags,
    this.isDeleted = false,
    this.isFavorite = false,
    this.category,
    this.color,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        tags = tags ?? [];

  bool get isRange => endTime != null;

  /// Duration in milliseconds (if endTime is set)
  int? get duration => endTime != null ? endTime! - time : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordId': recordId,
      'time': time,
      'endTime': endTime,
      'description': description,
      'image': image,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'tags': tags.isNotEmpty ? tags.join(',') : null,
      'isDeleted': isDeleted ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'category': category,
      'color': color,
    };
  }

  factory Timestamp.fromMap(Map<String, dynamic> map) {
    return Timestamp(
      id: map['id'],
      recordId: map['recordId'],
      time: map['time'],
      endTime: map['endTime'],
      description: map['description'],
      image: map['image'],
      dateCreated: DateTime.parse(map['dateCreated']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : [],
      isDeleted: map['isDeleted'] == 1,
      isFavorite: map['isFavorite'] == 1,
      category: map['category'],
      color: map['color'],
    );
  }

  Timestamp copyWith({
    int? id,
    int? recordId,
    int? time,
    int? endTime,
    String? description,
    String? image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    List<String>? tags,
    bool? isDeleted,
    bool? isFavorite,
    String? category,
    String? color,
  }) {
    return Timestamp(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      image: image ?? this.image,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}
