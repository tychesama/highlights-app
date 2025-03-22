import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection.dart';
import '../providers/record_provider.dart';
import '../providers/collection_provider.dart';
import '../sheets/edit_collection_sheet.dart';
import 'record_screen.dart';
import '../models/record.dart';
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
        // Delete records associated with this collection
        final recordProvider = Provider.of<RecordProvider>(
          context,
          listen: false,
        );
        final recordsToDelete =
            recordProvider.records
                .where((record) => record.collectionId == collection.id)
                .toList();

        // Delete each record
        for (final record in recordsToDelete) {
          await recordProvider.deleteRecord(record); // Pass the entire record
        }

        // Delete the collection
        await collectionProvider.deleteCollection(collection.id!);

        // Show success message for both collection and records
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection and records deleted.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Delete only the collection
        await collectionProvider.deleteCollection(collection.id!);

        // Show success message for collection only
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection deleted.'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh the search query and state
      final recordProvider = Provider.of<RecordProvider>(
        context,
        listen: false,
      );
      collectionProvider.updateSearchQuery('', recordProvider.records);
      recordProvider.updateSearchQuery('');

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  void _editRecord(BuildContext context, Record record, int? collectionId) {
    TextEditingController titleController = TextEditingController(
      text: record.name,
    );
    TextEditingController episodeController = TextEditingController(
      text: record.episode?.toString() ?? '',
    );
    TextEditingController notesController = TextEditingController(
      text: record.notes,
    );

    showDialog(
      context: context,
      builder: (editDialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Text("Edit Record"),
              Spacer(),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () async {
                  final confirmDelete = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: Text(
                            "Are you sure you want to permanently delete this record?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmDelete == true) {
                    final recordProvider = Provider.of<RecordProvider>(
                      editDialogContext,
                      listen: false,
                    );
                    await recordProvider.deleteRecord(record);

                    ScaffoldMessenger.of(editDialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Record deleted permanently!'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Close the edit dialog after deleting
                    Navigator.pop(editDialogContext);
                  }
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Enter title"),
              ),
              TextField(
                controller: episodeController,
                decoration: InputDecoration(labelText: "Episode Number"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(editDialogContext),
              child: Text("Cancel"),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final confirmRemove = await showDialog<bool>(
            //       context: context,
            //       builder:
            //           (dialogContext) => AlertDialog(
            //             title: Text("Remove from Collection"),
            //             content: Text(
            //               "Are you sure you want to remove this record from the collection?",
            //             ),
            //             actions: [
            //               TextButton(
            //                 onPressed:
            //                     () => Navigator.pop(dialogContext, false),
            //                 child: Text("Cancel"),
            //               ),
            //               TextButton(
            //                 onPressed: () => Navigator.pop(dialogContext, true),
            //                 child: Text(
            //                   "Remove",
            //                   style: TextStyle(color: Colors.orange),
            //                 ),
            //               ),
            //             ],
            //           ),
            //     );

            //     if (confirmRemove == true) {
            //       _removeFromCollection(context, record);
            //       Navigator.pop(
            //         context,
            //       ); // Close the edit dialog after removing
            //     }
            //   },
            //   child: Text("Remove"),
            //   style: TextButton.styleFrom(foregroundColor: Colors.orange),
            // ),
            ElevatedButton(
              onPressed: () {
                final updatedRecord = record.copyWith(
                  name: titleController.text,
                  episode: int.tryParse(episodeController.text),
                  notes: notesController.text,
                  collectionId: collectionId,
                  lastUpdated: DateTime.now(),
                );

                final recordProvider = Provider.of<RecordProvider>(
                  editDialogContext,
                  listen: false,
                );
                recordProvider.updateRecord(updatedRecord);

                ScaffoldMessenger.of(editDialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Record updated and added to collection!'),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pop(editDialogContext);
              },
              child: Text("Edit"),
            ),
          ],
        );
      },
    );
  }

  void _removeFromCollection(BuildContext context, Record record) {
  final recordProvider = Provider.of<RecordProvider>(context, listen: false);

  final updatedRecord = record.copyWith(collectionId: null, lastUpdated: DateTime.now());

  recordProvider.updateRecord(updatedRecord);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Record removed from collection!'),
      duration: Duration(seconds: 2),
    ),
  );
}


  void _addToCollection(
    Record record,
    int? collectionId,
    BuildContext context,
  ) {
    if (collectionId != null) {
      final updatedRecord = record.copyWith(collectionId: collectionId);

      // Assuming you have a RecordProvider that updates the records
      final recordProvider = Provider.of<RecordProvider>(
        context,
        listen: false,
      );
      recordProvider.updateRecord(
        updatedRecord,
      ); // Update the record in the provider

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record added to collection!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSelectRecordModal(BuildContext context, int? collectionId) {
    final recordProvider = Provider.of<RecordProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Record',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: recordProvider.filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = recordProvider.filteredRecords[index];

                    if (record.collectionId == null) {
                      return ListTile(
                        title: Text(record.name),
                        subtitle: Text("Episode: ${record.episode ?? 'N/A'}"),
                        onTap: () {
                          Navigator.pop(context);
                          _addToCollection(
                            record,
                            collectionId,
                            context,
                          ); // Add the record to the collection
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showSelectRecordModal(context, collection.id);
            },
          ),
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
                          // Normal tap: Navigate to the RecordScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RecordScreen(record: record),
                            ),
                          );
                        },
                        onLongPress: () {
                          // Long press: Open the edit record dialog
                          _editRecord(context, record, collection.id);
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
