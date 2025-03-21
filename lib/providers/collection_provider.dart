import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../services/database_helper.dart';

class CollectionProvider with ChangeNotifier {
  List<Collection> _collections = [];

  List<Collection> get collections => _collections;

  CollectionProvider() {
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    _collections = await DatabaseHelper.instance.getCollections();
    notifyListeners();
  }

  Future<void> addCollection(Collection collection) async {
    await DatabaseHelper.instance.insertCollection(collection);
    fetchCollections();
  }

  Future<void> deleteCollection(int id) async {
    await DatabaseHelper.instance.deleteCollection(id);
    fetchCollections();
  }
}
