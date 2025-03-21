import 'package:flutter/material.dart';
import '../models/collection.dart';

class CollectionProvider extends ChangeNotifier {
  List<Collection> _collections = [];

  List<Collection> get collections => _collections;

  void addCollection(Collection collection) {
    _collections.add(collection);
    notifyListeners();
  }
}
