import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../services/database_helper.dart';
import '../models/record.dart';

class CollectionProvider with ChangeNotifier {
  List<Collection> _collections = [];
  List<Collection> _filtered = [];
  String _searchQuery = '';

  List<Collection> get filteredCollections {
    if (_searchQuery.isEmpty) return _collections.where((c) => !c.isHidden && !c.isDeleted).toList();
    return _filtered;
  }

  void setCollections(List<Collection> collections) {
    _collections = collections;
    notifyListeners();
  }

  void updateSearchQuery(String query, List<Record> allRecords) {
    _searchQuery = query;
    final lowerQuery = query.toLowerCase();

    _filtered = _collections.where((collection) {
      if (collection.isHidden || collection.isDeleted) return false;
      final collectionMatches = collection.name.toLowerCase().contains(lowerQuery);
      final recordMatches = allRecords.any(
        (record) => record.collectionId == collection.id && record.name.toLowerCase().contains(lowerQuery),
      );
      return collectionMatches || recordMatches;
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filtered = [];
    notifyListeners();
  }

  CollectionProvider() {
    fetchCollections();
  }

  Collection? getCollectionById(int collectionId) {
    try {
      return _collections.firstWhere((collection) => collection.id == collectionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Collection>> fetchCollections() async {
    _collections = await DatabaseHelper.instance.getCollections();
    _collections.sort((a, b) => (b.lastAccessed ?? DateTime(2000)).compareTo(a.lastAccessed ?? DateTime(2000)));
    notifyListeners();
    return _collections;
  }

  Future<void> clearAllCollections() async {
    await DatabaseHelper.instance.clearAllCollections();
    _collections.clear();
    notifyListeners();
  }

  Future<void> addCollection(Collection collection) async {
    await DatabaseHelper.instance.insertCollection(collection);
    fetchCollections();
  }

  Future<void> softDeleteCollection(int id) async {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      _collections[index].isDeleted = true;
      await DatabaseHelper.instance.updateCollection(_collections[index]);
      notifyListeners();
    }
  }

  Future<void> restoreCollection(int id) async {
    final index = _collections.indexWhere((c) => c.id == id);
    if (index != -1) {
      _collections[index].isDeleted = false;
      await DatabaseHelper.instance.updateCollection(_collections[index]);
      notifyListeners();
    }
  }

  Future<void> updateCollection(Collection updatedCollection) async {
    await DatabaseHelper.instance.updateCollection(updatedCollection);
    final index = _collections.indexWhere((c) => c.id == updatedCollection.id);
    if (index != -1) {
      _collections[index] = updatedCollection;
      notifyListeners();
    }
  }

  void updateCollectionLastAccessed(int collectionId, DateTime newTime) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      _collections[index].lastAccessed = newTime;
      _collections.sort((a, b) => (b.lastAccessed ?? DateTime(2000)).compareTo(a.lastAccessed ?? DateTime(2000)));
      notifyListeners();
    }
  }

  void toggleFavorite(int collectionId) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      _collections[index].isFavorite = !_collections[index].isFavorite;
      DatabaseHelper.instance.updateCollection(_collections[index]);
      notifyListeners();
    }
  }

  void updateColor(int collectionId, String newColorHex) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      _collections[index].colorHex = newColorHex;
      DatabaseHelper.instance.updateCollection(_collections[index]);
      notifyListeners();
    }
  }

  void updateCollectionLastUpdated(int collectionId, DateTime newTime) {
    final index = _collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      _collections[index].lastUpdated = newTime;
      _collections.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      notifyListeners();
    }
  }
}
