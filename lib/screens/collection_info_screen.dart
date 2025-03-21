import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection.dart';
import '../models/record.dart';
import '../providers/record_provider.dart';
import 'record_screen.dart';
import 'dart:io';

class CollectionInfoScreen extends StatelessWidget {
  final Collection collection;

  const CollectionInfoScreen({Key? key, required this.collection})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(collection.name)),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                        collection.thumbnail != null &&
                                collection.thumbnail!.isNotEmpty
                            ? Image.file(
                              File(collection.thumbnail!),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey,
                              child: Icon(Icons.image, color: Colors.white54),
                            ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          collection.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Type: ${collection.type}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Season: ${collection.season}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          collection.description ?? 'No description',
                          style: TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created on: ${collection.dateCreated.toLocal().toString().split(" ").first}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 6,
            child: Consumer<RecordProvider>(
              builder: (context, recordProvider, child) {
                final records =
                    recordProvider.records
                        .where((record) => record.collectionId == collection.id)
                        .toList()
                      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

                if (records.isEmpty) {
                  return Center(
                    child: Text("No records found for this collection"),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RecordScreen(record: record),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    collection.thumbnail != null &&
                                            collection.thumbnail!.isNotEmpty
                                        ? Image.file(
                                          File(collection.thumbnail!),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey,
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.white54,
                                          ),
                                        ),
                              ),
                              SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      [
                                        if (record.episode != null)
                                          'Episode ${record.episode}',
                                      ].join(', '),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
