class Timestamp {
  int? id;
  int recordId;
  int time; // start time in milliseconds
  int? endTime; // optional end time
  String description;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;

  Timestamp({
    this.id,
    required this.recordId,
    required this.time,
    this.endTime,
    this.description = '',
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : dateCreated = dateCreated ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

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
    );
  }
}
