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
      version: 2,
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
            thumbnail TEXT
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
            FOREIGN KEY (recordId) REFERENCES records(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE timestamps (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              recordId INTEGER,
              time INTEGER,
              endTime INTEGER,
              description TEXT,
              image TEXT,
              dateCreated TEXT,
              lastUpdated TEXT,
              FOREIGN KEY (recordId) REFERENCES records(id) ON DELETE CASCADE
            )
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
    final maps = await db.query(
      'timestamps',
      where: 'recordId = ?',
      whereArgs: [recordId],
      orderBy: 'time ASC',
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
        thumbnail: maps[i]['thumbnail'],
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
      'timestamps': jsonEncode(record.timestamps),
      'notes': record.notes,
      'image': record.image,
    });

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

    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        name: maps[i]['name'],
        collectionId: maps[i]['collectionId'],
        episode: maps[i]['episode'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
        lastUpdated: DateTime.parse(maps[i]['lastUpdated']),
        timestamps: _decodeTimestamps(maps[i]['timestamps']),
        notes: maps[i]['notes'],
        image: maps[i]['image'],
      );
    });
  }

  Future<List<Record>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records');

    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        name: maps[i]['name'],
        collectionId: maps[i]['collectionId'],
        episode: maps[i]['episode'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
        lastUpdated: DateTime.parse(maps[i]['lastUpdated']),
        timestamps: _decodeTimestamps(maps[i]['timestamps']),
        notes: maps[i]['notes'],
        image: maps[i]['image'],
      );
    });
  }

  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      'records',
      {
        'name': record.name,
        'collectionId': record.collectionId,
        'episode': record.episode,
        'lastUpdated': DateTime.now().toIso8601String(),
        'timestamps': jsonEncode(record.timestamps),
        'notes': record.notes,
        'image': record.image,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
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
    await db.delete('records');
  }

  Future<void> clearAllCollections() async {
    final db = await database;
    await db.delete('collections');
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
