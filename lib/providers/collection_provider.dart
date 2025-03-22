import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../services/database_helper.dart';
import '../models/record.dart';

class CollectionProvider with ChangeNotifier {
  List<Collection> _collections = [];
  List<Collection> _filtered = [];
  String _searchQuery = '';

  List<Collection> get filteredCollections {
    if (_searchQuery.isEmpty) return _collections;
    return _filtered;
  }

  void setCollections(List<Collection> collections) {
    _collections = collections;
    notifyListeners();
  }

  void updateSearchQuery(String query, List<Record> allRecords) {
    _searchQuery = query;
    final lowerQuery = query.toLowerCase();

    _filtered =
        _collections.where((collection) {
          final collectionMatches = collection.name.toLowerCase().contains(
            lowerQuery,
          );

          final recordMatches = allRecords.any(
            (record) =>
                record.collectionId == collection.id &&
                record.name.toLowerCase().contains(lowerQuery),
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
      return _collections.firstWhere(
        (collection) => collection.id == collectionId,
      );
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

  Future<void> updateCollection(Collection updatedCollection) async {
    await DatabaseHelper.instance.updateCollection(updatedCollection);

    final index = _collections.indexWhere((c) => c.id == updatedCollection.id);
    if (index != -1) {
      _collections[index] = updatedCollection;
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
