import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection.dart';
import '../providers/record_provider.dart';
import '../providers/collection_provider.dart';
import '../sheets/edit_collection_sheet.dart';
import 'record_screen.dart';
import 'dart:io';

class CollectionInfoScreen extends StatelessWidget {
  final Collection collection;

  const CollectionInfoScreen({Key? key, required this.collection})
    : super(key: key);

  void _confirmDelete(BuildContext context) async {
    bool deleteRecords = false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Collection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to delete this collection?'),
                  SizedBox(height: 12),
                  CheckboxListTile(
                    title: Text('Delete all records'),
                    value: deleteRecords,
                    onChanged: (value) {
                      setState(() {
                        deleteRecords = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(deleteRecords),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm != null) {
      final collectionProvider = Provider.of<CollectionProvider>(
        context,
        listen: false,
      );

      if (confirm == true) {
        final recordProvider = Provider.of<RecordProvider>(
          context,
          listen: false,
        );
        final recordsToDelete =
            recordProvider.records
                .where((record) => record.collectionId == collection.id)
                .toList();

        for (final record in recordsToDelete) {
          await recordProvider.deleteRecord(record.id!);
        }

        await collectionProvider.deleteCollection(collection.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection and records deleted.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await collectionProvider.deleteCollection(collection.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection deleted.'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final recordProvider = Provider.of<RecordProvider>(
        context,
        listen: false,
      );
      collectionProvider.updateSearchQuery('', recordProvider.records);
      recordProvider.updateSearchQuery('');

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionProvider = Provider.of<CollectionProvider>(context);
    final latestCollection = collectionProvider.filteredCollections.firstWhere(
      (c) => c.id == collection.id,
      orElse: () => collection,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder:
                      (_) => EditCollectionSheet(collection: latestCollection),
                );
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
          ),
        ],
      ),
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
                        latestCollection.thumbnail != null &&
                                latestCollection.thumbnail!.isNotEmpty
                            ? Image.file(
                              File(latestCollection.thumbnail!),
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
                          latestCollection.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Type: ${latestCollection.type}',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (latestCollection.season != null)
                          Text(
                            'Season: ${latestCollection.season}',
                            style: TextStyle(fontSize: 16),
                          ),

                        SizedBox(height: 8),
                        Text(
                          latestCollection.description ?? 'No description',
                          style: TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created on: ${latestCollection.dateCreated.toLocal().toString().split(" ").first}',
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
                                    latestCollection.thumbnail != null &&
                                            latestCollection
                                                .thumbnail!
                                                .isNotEmpty
                                        ? Image.file(
                                          File(latestCollection.thumbnail!),
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
