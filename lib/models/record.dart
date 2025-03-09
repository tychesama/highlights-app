import 'type.dart';

class Record {
  String name;
  Type type;
  String? notes;
  String? image;
  DateTime dateCreated;
  DateTime lastUpdated;
  final List<Map<String, dynamic>> _timestamps = [];

  Record({
    required this.name,
    required this.type,
    this.notes,
    this.image,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

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
}
