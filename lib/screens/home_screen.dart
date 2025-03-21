import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../providers/collection_provider.dart';
import '../models/record.dart';
import '../models/collection.dart';
import 'record_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showNewRecordDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController episodeController = TextEditingController();
    String selectedCollection = "Default";

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
                      "Collection 1",
                      "Collection 2",
                    ] // Replace with dynamic collections later
                    .map((collection) {
                      return DropdownMenuItem<String>(
                        value: collection,
                        child: Text(collection),
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
                final recordProvider = Provider.of<RecordProvider>(
                  context,
                  listen: false,
                );

                Record newRecord = Record(
                  name:
                      titleController.text.isNotEmpty
                          ? titleController.text
                          : "Untitled",
                  collection: Collection(
                    name: selectedCollection,
                    type: "", // Adjust as needed
                    season: 1,
                    description: "",
                  ),
                  episode: int.tryParse(episodeController.text) ?? 1,
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
    String selectedType = "Anime";
    List<String> types = ["Anime", "Movie", "Series", "Others"];

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
            icon: Icon(Icons.more_vert), // Triple-dot icon
          ),
        ],
      ),
      body: Column(
        children: [
          // Collection Section
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
                      print(
                        "Collections count: ${collectionProvider.collections.length}",
                      );

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: collectionProvider.collections.length,
                        itemBuilder: (context, index) {
                          final collection =
                              collectionProvider.collections[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Card(
                              child: SizedBox(
                                width: 150,
                                child: Center(child: Text(collection.name)),
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
          // Episodes Section
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Episodes",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // PRESS ME HERE
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
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(20),
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
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Created: ${record.dateCreated}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.black54),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewRecordDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
