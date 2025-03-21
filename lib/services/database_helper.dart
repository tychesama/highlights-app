import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';
import '../models/collection.dart';
import 'dart:convert';
import '../services/database_helper.dart';

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
      version: 1,
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
            timestamps TEXT,
            notes TEXT,
            image TEXT,
            FOREIGN KEY (collectionId) REFERENCES collections(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Insert Collection
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

  // Get all Collections
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

  // Delete Collection
  Future<int> deleteCollection(int id) async {
    final db = await database;
    return await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  // Update Collection
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

  // Insert Record
  Future<int> insertRecord(Record record) async {
    final db = await database;
    return await db.insert('records', {
      'name': record.name,
      'collectionId': record.collection?.id,
      'episode': record.episode,
      'dateCreated': record.dateCreated.toIso8601String(),
      'lastUpdated': record.lastUpdated.toIso8601String(),
      'timestamps': record.timestamps.toString(),
      'notes': record.notes,
      'image': record.image,
    });
  }

  // Get Records by Collection ID
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
        collection: Collection(
          id: maps[i]['collectionId'],
          name: "",
        ), // Fetch full collection separately if needed
        episode: maps[i]['episode'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
        lastUpdated: DateTime.parse(maps[i]['lastUpdated']),
        timestamps: _decodeTimestamps(maps[i]['timestamps']),
        notes: maps[i]['notes'],
        image: maps[i]['image'],
      );
    });
  }

  // Delete Record
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  // Update Record
  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      'records',
      {
        'name': record.name,
        'collectionId': record.collection?.id,
        'episode': record.episode,
        'lastUpdated': DateTime.now().toIso8601String(),
        'timestamps': record.timestamps.toString(),
        'notes': record.notes,
        'image': record.image,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Fetch all Record
  Future<List<Record>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records');

    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        name: maps[i]['name'],
        collection: Collection(id: maps[i]['collectionId'], name: ""),
        episode: maps[i]['episode'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
        lastUpdated: DateTime.parse(maps[i]['lastUpdated']),
        timestamps: _decodeTimestamps(maps[i]['timestamps']),
        notes: maps[i]['notes'],
        image: maps[i]['image'],
      );
    });
  }

  // Helper to Decode JSON
  List<Map<String, dynamic>> _decodeTimestamps(String json) {
    return (jsonDecode(json) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }




  // debugging
  Future<void> viewAllData() async {
    final db = await database;

    // Fetch records
    final records = await db.query('records'); // 'records' is the table name
    for (var record in records) {
      print(record); // Print each record to the console
    }

    // Fetch collections
    final collections = await db.query('collections'); // 'collections' is the table name
    for (var collection in collections) {
      print(collection); // Print each collection to the console
    }
  }

}
