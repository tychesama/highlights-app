import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/record_provider.dart';
import '../../providers/collection_provider.dart';
import '../../models/record.dart';
import '../../models/collection.dart';
import '../record_screen/record_screen.dart';
import '../collection_info_screen.dart';
import 'dart:io';
import '../../services/database_helper.dart';
import 'settings_screen.dart';
import '../record_screen/main_record_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0 && !_isAtTop) {
        setState(() {
          _isAtTop = true;
        });
      } else if (_scrollController.position.pixels > 0 && _isAtTop) {
        setState(() {
          _isAtTop = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _editRecord(BuildContext context, Record record) {
    TextEditingController titleController = TextEditingController(
      text: record.name,
    );
    TextEditingController episodeController = TextEditingController(
      text: record.episode?.toString() ?? '',
    );
    TextEditingController notesController = TextEditingController(
      text: record.notes,
    );
    int? selectedCollectionId = record.collectionId;

    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );
    final collections = collectionProvider.filteredCollections;

    showDialog(
      context: context,
      builder: (editDialogContext) {
        // Store context for the edit dialog
        return AlertDialog(
          title: Row(
            children: [
              Text("Edit Record"),
              Spacer(),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () async {
                  Navigator.of(
                    editDialogContext,
                    rootNavigator: true,
                  ).pop(); // Close edit modal

                  final confirmDelete = await showDialog<bool>(
                    context: editDialogContext,
                    builder:
                        (confirmDialogContext) => AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: Text(
                            "Are you sure you want to delete this record?",
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => Navigator.pop(
                                    confirmDialogContext,
                                    false,
                                  ),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed:
                                  () =>
                                      Navigator.pop(confirmDialogContext, true),
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
                      context,
                      listen: false,
                    );
                    await recordProvider.deleteRecord(record);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Record deleted!')));
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
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: episodeController,
                decoration: InputDecoration(labelText: "Episode"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<int>(
                value: selectedCollectionId,
                decoration: InputDecoration(labelText: "Collection"),
                items:
                    collections.map((collection) {
                      return DropdownMenuItem<int>(
                        value: collection.id,
                        child: Text(collection.name),
                      );
                    }).toList(),
                onChanged: (value) => selectedCollectionId = value,
              ),
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
            ElevatedButton(
              onPressed: () {
                final updatedRecord = record.copyWith(
                  name: titleController.text,
                  episode: int.tryParse(episodeController.text),
                  notes: notesController.text,
                  collectionId: selectedCollectionId,
                  lastUpdated: DateTime.now(),
                );

                final recordProvider = Provider.of<RecordProvider>(
                  context,
                  listen: false,
                );
                recordProvider.updateRecord(updatedRecord);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Record updated!')));
                Navigator.pop(editDialogContext);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showNewRecordDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController episodeController = TextEditingController();
    TextEditingController notesController = TextEditingController();
    int? selectedCollectionId;

    final collectionProvider = Provider.of<CollectionProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Record"),
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
              DropdownButtonFormField<int?>(
                value: selectedCollectionId,
                onChanged: (newValue) {
                  selectedCollectionId = newValue;
                },
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text("No Collection"),
                  ),
                  ...collectionProvider.filteredCollections.map((collection) {
                    return DropdownMenuItem<int?>(
                      value: collection.id,
                      child: Text(collection.name),
                    );
                  }).toList(),
                ],
                decoration: InputDecoration(labelText: "Select Collection"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newRecord = Record(
                  name:
                      titleController.text.isNotEmpty
                          ? titleController.text
                          : "Untitled",
                  collectionId: selectedCollectionId,
                  episode: int.tryParse(episodeController.text),
                  notes: notesController.text,
                  image: "",
                  dateCreated: DateTime.now(),
                  lastUpdated: DateTime.now(),
                  timestamps: [],
                );

                final recordProvider = Provider.of<RecordProvider>(
                  context,
                  listen: false,
                );

                final collectionProvider = Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                );

                final newId = await recordProvider.addRecord(newRecord);
                final createdRecord = await recordProvider.getRecordById(newId);

                Navigator.pop(context);

                if (createdRecord != null) {
                  final selectedCollection =
                      selectedCollectionId != null
                          ? collectionProvider.getCollectionById(
                            selectedCollectionId!,
                          )
                          : null;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MainRecordScreen(
                            record: createdRecord,
                            collection: selectedCollection,
                          ),
                    ),
                  );
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showNewCollectionDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController seasonController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String selectedType = "Livestream";
    List<String> types = [
      "Livestream",
      "Anime",
      "Movie",
      "Series",
      "Sports Game",
      "Others",
    ];
    String? thumbnailPath;

    void _pickThumbnail() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          thumbnailPath = pickedFile.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("New Collection"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Collection Name",
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        onChanged: (newValue) {
                          setState(() {
                            selectedType = newValue!;
                          });
                        },
                        items:
                            types.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        decoration: InputDecoration(labelText: "Select Type"),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: seasonController,
                        decoration: InputDecoration(
                          labelText: "Season (Optional)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                        ),
                        maxLines: 2,
                      ),

                      SizedBox(height: 10),
                      if (thumbnailPath == null)
                        ElevatedButton(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setState(() {
                                thumbnailPath = pickedFile.path;
                              });
                            }
                          },
                          child: Text("Select Thumbnail"),
                        ),
                      if (thumbnailPath != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                            onTap: () async {
                              final pickedFile = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  thumbnailPath = pickedFile.path;
                                });
                              }
                            },
                            child: Image.file(
                              File(thumbnailPath!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final collectionProvider = Provider.of<CollectionProvider>(
                      context,
                      listen: false,
                    );

                    final newCollection = Collection(
                      name:
                          nameController.text.isNotEmpty
                              ? nameController.text
                              : "Untitled",
                      type: selectedType,
                      season: int.tryParse(seasonController.text),
                      description: descriptionController.text,
                      dateCreated: DateTime.now(),
                      lastUpdated: DateTime.now(),
                      thumbnail: thumbnailPath,
                    );

                    final insertedId = await collectionProvider.addCollection(
                      newCollection,
                    );
                    final insertedCollection = await collectionProvider
                        .getCollectionById(insertedId);

                    if (insertedCollection != null) {
                      Navigator.pop(context); // close dialog

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CollectionInfoScreen(
                                collection: insertedCollection,
                              ),
                        ),
                      );

                      
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load new collection'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },

                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    final recordProvider = Provider.of<RecordProvider>(
                      context,
                      listen: false,
                    );
                    final collectionProvider = Provider.of<CollectionProvider>(
                      context,
                      listen: false,
                    );

                    collectionProvider.updateSearchQuery(
                      value,
                      recordProvider.records,
                    );
                    recordProvider.updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
                : Text("Highlights"),
        leading:
            _isSearching
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });

                    final recordProvider = Provider.of<RecordProvider>(
                      context,
                      listen: false,
                    );
                    final collectionProvider = Provider.of<CollectionProvider>(
                      context,
                      listen: false,
                    );

                    recordProvider.updateSearchQuery('');
                    collectionProvider.updateSearchQuery(
                      '',
                      recordProvider.records,
                    );
                  },
                )
                : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              print("Selected: $value");
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: "Settings", child: Text("Settings")),
                  PopupMenuItem(value: "Help", child: Text("Help")),
                  PopupMenuItem(value: "About", child: Text("About")),
                ],
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Collection",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _showNewCollectionDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<CollectionProvider>(
                    builder: (context, collectionProvider, child) {
                      final sortedCollections = [
                        ...collectionProvider.filteredCollections,
                      ]..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

                      if (sortedCollections.isEmpty) {
                        return Center(child: Text("No collection found"));
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedCollections.length,
                        itemBuilder: (context, index) {
                          final collection = sortedCollections[index];
                          return KeyedSubtree(
                            key: ValueKey(collection.id),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CollectionInfoScreen(
                                            collection: collection,
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(-3, -3),
                                          blurRadius: 6,
                                        ),
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(3, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          collection.thumbnail != null &&
                                                  collection
                                                      .thumbnail!
                                                      .isNotEmpty
                                              ? Opacity(
                                                opacity: 0.7,
                                                child: Image.file(
                                                  File(collection.thumbnail!),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              )
                                              : Container(color: Colors.grey),
                                          Center(
                                            child: Text(
                                              collection.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
          ),
          // Records Section
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Records",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _showNewRecordDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer2<RecordProvider, CollectionProvider>(
                    builder: (
                      context,
                      recordProvider,
                      collectionProvider,
                      child,
                    ) {
                      if (recordProvider.filteredRecords.isEmpty) {
                        return Center(child: Text("No records found"));
                      }

                      final sortedRecords = [
                        ...recordProvider.filteredRecords,
                      ]..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

                      return Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: sortedRecords.length,
                            itemBuilder: (context, index) {
                              final record = sortedRecords[index];

                              final Collection? collection =
                                  record.collectionId != null
                                      ? collectionProvider.filteredCollections
                                          .firstWhere(
                                            (c) => c.id == record.collectionId,
                                            orElse:
                                                () => Collection(
                                                  id: -1,
                                                  name: "Unknown",
                                                  season: 0,
                                                  thumbnail: "",
                                                ),
                                          )
                                      : null;

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MainRecordScreen(
                                              record: record,
                                              collection: collection,
                                            ),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    // Trigger edit functionality here
                                    _editRecord(context, record);
                                  },
                                  child: InkWell(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (collection?.thumbnail != null &&
                                              collection!.thumbnail!.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                File(collection.thumbnail!),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  record.name.isNotEmpty &&
                                                          record.name !=
                                                              "Untitled"
                                                      ? record.name
                                                      : (() {
                                                        final season =
                                                            (collection?.season ??
                                                                        0) >
                                                                    0
                                                                ? "S${collection!.season}"
                                                                : "";
                                                        final episode =
                                                            record.episode !=
                                                                    null
                                                                ? "Episode ${record.episode}"
                                                                : "";
                                                        final title = [
                                                              season,
                                                              episode,
                                                            ]
                                                            .where(
                                                              (s) =>
                                                                  s.isNotEmpty,
                                                            )
                                                            .join(", ");
                                                        return title.isNotEmpty
                                                            ? title
                                                            : "Untitled";
                                                      })(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                        fontSize: 14,
                                                      ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  (() {
                                                    final season =
                                                        (collection?.season ??
                                                                    0) >
                                                                0
                                                            ? "S${collection!.season}"
                                                            : "";
                                                    final episode =
                                                        record.episode != null
                                                            ? "Episode ${record.episode}"
                                                            : "";
                                                    final title = [
                                                          season,
                                                          episode,
                                                        ]
                                                        .where(
                                                          (s) => s.isNotEmpty,
                                                        )
                                                        .join(", ");
                                                    return record
                                                                .name
                                                                .isNotEmpty &&
                                                            record.name !=
                                                                "Untitled" &&
                                                            title.isNotEmpty
                                                        ? "$title  |  ${collection?.name ?? "No Collection"}"
                                                        : collection?.name ??
                                                            "No Collection";
                                                  })(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.black54,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "Duration: --:--", // Placeholder for duration
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.black45,
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (!_isAtTop)
                            Positioned(
                              bottom: 16,
                              right: 20,
                              child: FloatingActionButton(
                                onPressed: () {
                                  _scrollController.animateTo(
                                    0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Icon(Icons.arrow_upward),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
