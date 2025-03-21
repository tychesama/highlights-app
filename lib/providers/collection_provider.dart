import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../services/database_helper.dart';

class CollectionProvider with ChangeNotifier {
  List<Collection> _collections = [];

  List<Collection> get collections => _collections;

  CollectionProvider() {
    fetchCollections();
  }

  Collection? getCollectionById(int collectionId) {
    try {
      return collections.firstWhere((collection) => collection.id == collectionId);
    } catch (e) {
      return null; 
    }
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
