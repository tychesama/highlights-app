import 'package:flutter/material.dart';

/// Base Type Class
abstract class Type {
  final String name;
  DateTime dateCreated;
  DateTime lastUpdated;

  Type({
    required this.name,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();
}

/// Series Type
class Series extends Type {
  String title;
  int season;
  int episode;
  String description;

  Series({
    required this.title,
    required this.season,
    required this.episode,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);
}

/// Movie Type
class Movie extends Type {
  String title;
  String description;

  Movie({
    required this.title,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);
}

/// Anime Type (Similar to Series)
class Anime extends Type {
  String title;
  int season;
  int episode;
  String description;

  Anime({
    required this.title,
    required this.season,
    required this.episode,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);
}

/// Stream Type
class Stream extends Type {
  String title;
  String description;

  Stream({
    required this.title,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);
}

/// Others Type
class Others extends Type {
  String title;
  String description;

  Others({
    required this.title,
    required this.description,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) : super(name: title, dateCreated: dateCreated, lastUpdated: lastUpdated);
}
