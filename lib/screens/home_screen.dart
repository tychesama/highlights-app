import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/record_provider.dart';
import '../providers/collection_provider.dart';
import '../models/record.dart';
import '../models/collection.dart';
import 'record_screen.dart';
import 'collection_info_screen.dart';
import 'dart:io';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showNewRecordDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController episodeController = TextEditingController();
    TextEditingController notesController = TextEditingController();
    String? selectedCollection;

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
              DropdownButtonFormField<String>(
                value: selectedCollection,
                onChanged: (newValue) {
                  selectedCollection = newValue!;
                },
                items:
                    [
                      "Default",
                      ...Provider.of<CollectionProvider>(context, listen: false)
                          .collections
                          .map((collection) => collection.name)
                          .toList(),
                    ].map((collectionName) {
                      return DropdownMenuItem<String>(
                        value: collectionName,
                        child: Text(collectionName),
                      );
                    }).toList(),
                decoration: InputDecoration(labelText: "Select Collection"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final collectionProvider = Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                );
                final collection = collectionProvider.collections.firstWhere(
                  (coll) => coll.name == selectedCollection,
                );

                final newRecord = Record(
                  name:
                      titleController.text.isNotEmpty
                          ? titleController.text
                          : "Untitled",
                  collection: collection,
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
                recordProvider.addRecord(newRecord);

                Navigator.pop(context);
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

    Future<void> _pickThumbnail() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          thumbnailPath = image.path;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Collection"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Collection Name"),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                onChanged: (newValue) {
                  selectedType = newValue!;
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
                decoration: InputDecoration(labelText: "Season (Optional)"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickThumbnail,
                child: Text("Select Thumbnail"),
              ),
              if (thumbnailPath != null)
                Image.file(
                  File(thumbnailPath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final collectionProvider = Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                );

                Collection newCollection = Collection(
                  name:
                      nameController.text.isNotEmpty
                          ? nameController.text
                          : "Untitled",
                  type: selectedType,
                  season: int.tryParse(seasonController.text) ?? 1,
                  description: descriptionController.text,
                  dateCreated: DateTime.now(),
                  lastUpdated: DateTime.now(),
                  thumbnail: thumbnailPath,
                );

                collectionProvider.addCollection(newCollection);
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
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
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: collectionProvider.collections.length,
                        itemBuilder: (context, index) {
                          final collection =
                              collectionProvider.collections[index];
                          return Padding(
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
                                        color: Color.fromRGBO(0, 0, 0, 0.2),
                                        offset: Offset(-3, -3),
                                        blurRadius: 6,
                                      ),
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.2),
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
                                                collection.thumbnail!.isNotEmpty
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
                                          ),
                                        ),
                                      ],
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
                  child: Consumer<RecordProvider>(
                    builder: (context, recordProvider, child) {
                      if (recordProvider.records.isEmpty) {
                        return Center(child: Text("No records found"));
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recordProvider.records.length,
                        itemBuilder: (context, index) {
                          final record = recordProvider.records[index];

                          final collection = record.collection;
                          print('Record Name: ${record.name}');
                          print('Record Collection: ${record.collection}');
                          print('Collection Name: ${record.collection?.name}');
                          print('Collection Season: ${record.collection?.season}');
                          print('Episode: ${record.episode}');

                          print(' Collection Name: ${collection?.name}');
                          print(' Collection Season: ${collection?.season}');


                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RecordScreen(record: record),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      collection != null
                                          ? "S${collection.season}, Episode ${record.episode}  |  ${collection.name}"
                                          : "S${record.episode} | No Collection", // Show episode if no collection
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('Home pressed');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(Icons.house),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('Star pressed');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(Icons.star),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('Notifications pressed');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(Icons.notifications),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    DatabaseHelper.instance.viewAllData();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.transparent,
                    child: Icon(Icons.settings),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
