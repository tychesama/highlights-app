import 'package:flutter/material.dart';
import '../models/collection.dart';
import 'dart:io';

class CollectionInfoScreen extends StatelessWidget {
  final Collection collection;  // Accept collection details as an argument

  const CollectionInfoScreen({Key? key, required this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the thumbnail (if available)
            collection.thumbnail != null && collection.thumbnail!.isNotEmpty
                ? Image.file(
                    File(collection.thumbnail!),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey,
                  ),
            SizedBox(height: 16),
            Text(
              'Type: ${collection.type}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Season: ${collection.season}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Description: ${collection.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Created on: ${collection.dateCreated.toLocal().toString()}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
