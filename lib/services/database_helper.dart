import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';
import '../models/collection.dart';
import '../models/timestamp.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;
  static const String dbName = 'highlights.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE collections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          type TEXT,
          season INTEGER,
          description TEXT,
          dateCreated TEXT,
          lastUpdated TEXT,
          thumbnail TEXT,
          totalRecords INTEGER,
          isFavorite INTEGER DEFAULT 0,
          status TEXT,
          lastAccessed TEXT,
          isHidden INTEGER DEFAULT 0,
          isDeleted INTEGER DEFAULT 0,
          colorHex TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          collectionId INTEGER,
          episode INTEGER,
          dateCreated TEXT,
          lastUpdated TEXT,
          notes TEXT,
          image TEXT,
          duration INTEGER,
          isFavorite INTEGER DEFAULT 0,
          lastAccessed TEXT,
          isHidden INTEGER DEFAULT 0,
          isDeleted INTEGER DEFAULT 0,
          colorHex TEXT,
          playbackSpeed REAL,
          FOREIGN KEY (collectionId) REFERENCES collections(id) ON DELETE CASCADE
        )
      ''');

        await db.execute('''
        CREATE TABLE timestamps (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recordId INTEGER NOT NULL,
          time INTEGER,
          endTime INTEGER,
          description TEXT,
          image TEXT,
          dateCreated TEXT,
          lastUpdated TEXT,
          tags TEXT,  -- Stored as comma-separated values
          isDeleted INTEGER DEFAULT 0,
          isFavorite INTEGER DEFAULT 0,
          category TEXT,
          color TEXT,
          FOREIGN KEY (recordId) REFERENCES records(id) ON DELETE CASCADE
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add the new columns to existing tables
          await db.execute('''
          ALTER TABLE collections ADD COLUMN totalRecords INTEGER;
          ALTER TABLE collections ADD COLUMN isFavorite INTEGER DEFAULT 0;
          ALTER TABLE collections ADD COLUMN status TEXT;
          ALTER TABLE collections ADD COLUMN lastAccessed TEXT;
          ALTER TABLE collections ADD COLUMN isHidden INTEGER DEFAULT 0;
          ALTER TABLE collections ADD COLUMN isDeleted INTEGER DEFAULT 0;
          ALTER TABLE collections ADD COLUMN colorHex TEXT;
        ''');

          await db.execute('''
          ALTER TABLE records ADD COLUMN duration INTEGER;
          ALTER TABLE records ADD COLUMN isFavorite INTEGER DEFAULT 0;
          ALTER TABLE records ADD COLUMN lastAccessed TEXT;
          ALTER TABLE records ADD COLUMN isHidden INTEGER DEFAULT 0;
          ALTER TABLE records ADD COLUMN isDeleted INTEGER DEFAULT 0;
          ALTER TABLE records ADD COLUMN colorHex TEXT;
          ALTER TABLE records ADD COLUMN playbackSpeed REAL;
        ''');

          await db.execute('''
          ALTER TABLE timestamps ADD COLUMN tags TEXT;
          ALTER TABLE timestamps ADD COLUMN isDeleted INTEGER DEFAULT 0;
          ALTER TABLE timestamps ADD COLUMN isFavorite INTEGER DEFAULT 0;
          ALTER TABLE timestamps ADD COLUMN category TEXT;
          ALTER TABLE timestamps ADD COLUMN color TEXT;
        ''');
        }
      },
    );
  }

  Future<int> insertTimestamp(Timestamp timestamp) async {
    final db = await database;
    return await db.insert('timestamps', {
      'recordId': timestamp.recordId,
      'time': timestamp.time,
      'endTime': timestamp.endTime,
      'description': timestamp.description,
      'image': timestamp.image,
      'dateCreated': timestamp.dateCreated.toIso8601String(),
      'lastUpdated': timestamp.lastUpdated.toIso8601String(),
      'tags': timestamp.tags?.join(
        ',',
      ), // Convert list to comma-separated string
      'isDeleted': timestamp.isDeleted ? 1 : 0,
      'isFavorite': timestamp.isFavorite ? 1 : 0,
      'category': timestamp.category,
      'color': timestamp.color,
    });
  }

  Future<int> updateTimestamp(Timestamp timestamp) async {
    final db = await database;
    return await db.update(
      'timestamps',
      {
        'recordId': timestamp.recordId,
        'time': timestamp.time,
        'endTime': timestamp.endTime,
        'description': timestamp.description,
        'image': timestamp.image,
        'lastUpdated': DateTime.now().toIso8601String(),
        'tags': timestamp.tags?.join(','), // Convert list to string
        'isDeleted': timestamp.isDeleted ? 1 : 0,
        'isFavorite': timestamp.isFavorite ? 1 : 0,
        'category': timestamp.category,
        'color': timestamp.color,
      },
      where: 'id = ?',
      whereArgs: [timestamp.id],
    );
  }

  Future<int> deleteTimestamp(int id) async {
    final db = await database;
    return await db.delete('timestamps', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Timestamp>> getTimestampsByRecordId(int recordId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'timestamps',
      where: 'recordId = ? AND isDeleted = 0', // Exclude deleted timestamps
      whereArgs: [recordId],
    );
    return maps.map((map) => Timestamp.fromMap(map)).toList();
  }

  Future<int> insertCollection(Collection collection) async {
    final db = await database;
    return await db.insert('collections', {
      'name': collection.name,
      'type': collection.type,
      'season': collection.season,
      'description': collection.description,
      'dateCreated': collection.dateCreated.toIso8601String(),
      'lastUpdated': collection.lastUpdated.toIso8601String(),
      'thumbnail': collection.thumbnail,
    });
  }

  Future<List<Collection>> getCollections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('collections');

    return List.generate(maps.length, (i) {
      return Collection(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        season: maps[i]['season'],
        description: maps[i]['description'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
        lastUpdated: DateTime.parse(maps[i]['lastUpdated']),
        thumbnail: maps[i]['thumbnail'], // Ensure this is correctly retrieved
      );
    });
  }

  Future<int> deleteCollection(int id) async {
    final db = await database;
    return await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCollection(Collection collection) async {
    final db = await database;
    return await db.update(
      'collections',
      {
        'name': collection.name,
        'type': collection.type,
        'season': collection.season,
        'description': collection.description,
        'lastUpdated': DateTime.now().toIso8601String(),
        'thumbnail': collection.thumbnail,
      },
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }

  Future<int> insertRecord(Record record) async {
    final db = await database;
    final now = DateTime.now();
    record.lastUpdated = now;

    final recordId = await db.insert('records', {
      'name': record.name,
      'collectionId': record.collectionId,
      'episode': record.episode,
      'dateCreated': record.dateCreated.toIso8601String(),
      'lastUpdated': record.lastUpdated.toIso8601String(),
      'notes': record.notes,
      'image': record.image,
    });

    for (var timestamp in record.timestamps) {
      await insertTimestamp(timestamp..recordId = recordId);
    }

    if (record.collectionId != null) {
      await db.update(
        'collections',
        {'lastUpdated': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [record.collectionId],
      );
    }

    return recordId;
  }

  Future<List<Record>> getRecordsByCollection(int collectionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    List<Record> records = [];
    for (var map in maps) {
      List<Timestamp> timestamps = await getTimestampsByRecordId(map['id']);
      records.add(
        Record(
          id: map['id'],
          name: map['name'],
          collectionId: map['collectionId'],
          episode: map['episode'],
          dateCreated: DateTime.parse(map['dateCreated']),
          lastUpdated: DateTime.parse(map['lastUpdated']),
          timestamps: timestamps,
          notes: map['notes'],
          image: map['image'],
        ),
      );
    }
    return records;
  }

  Future<List<Record>> getAllRecords({bool includeDeleted = false}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: includeDeleted ? null : 'isDeleted = 0',
    );

    List<Record> records = [];
    for (var map in maps) {
      List<Timestamp> timestamps = await getTimestampsByRecordId(map['id']);
      records.add(
        Record(
          id: map['id'],
          name: map['name'],
          collectionId: map['collectionId'],
          episode: map['episode'],
          dateCreated: DateTime.parse(map['dateCreated']),
          lastUpdated: DateTime.parse(map['lastUpdated']),
          timestamps: timestamps,
          notes: map['notes'],
          image: map['image'],
          duration: map['duration'],
          isFavorite: map['isFavorite'] == 1,
          lastAccessed:
              map['lastAccessed'] != null
                  ? DateTime.parse(map['lastAccessed'])
                  : null,
          isHidden: map['isHidden'] == 1,
          isDeleted: map['isDeleted'] == 1,
          colorHex: map['colorHex'],
          playbackSpeed: map['playbackSpeed'],
        ),
      );
    }
    return records;
  }

  Future<int> updateRecord(Record record) async {
    final db = await database;
    final now = DateTime.now();

    int result = await db.update(
      'records',
      {
        'name': record.name,
        'collectionId': record.collectionId,
        'episode': record.episode,
        'lastUpdated': now.toIso8601String(),
        'notes': record.notes,
        'image': record.image,
        'duration': record.duration,
        'isFavorite': record.isFavorite ? 1 : 0,
        'lastAccessed': record.lastAccessed?.toIso8601String(),
        'isHidden': record.isHidden ? 1 : 0,
        'isDeleted': record.isDeleted ? 1 : 0,
        'colorHex': record.colorHex,
        'playbackSpeed': record.playbackSpeed,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );

    if (record.collectionId != null) {
      await db.update(
        'collections',
        {'lastUpdated': now.toIso8601String()},
        where: 'id = ?',
        whereArgs: [record.collectionId],
      );
    }

    return result;
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  List<Timestamp> _decodeTimestamps(String json) {
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => Timestamp.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> clearAllRecords() async {
    final db = await database;
    await db.rawDelete('DELETE FROM records');
  }

  Future<void> clearAllCollections() async {
    final db = await database;
    await db.rawDelete('DELETE FROM collections');
  }

  Future<void> viewAllData() async {
    final db = await database;
    final records = await db.query('records');
    for (var record in records) {
      print(record);
    }
    final collections = await db.query('collections');
    for (var collection in collections) {
      print(collection);
    }
  }
}
