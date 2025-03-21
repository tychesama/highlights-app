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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showNewRecordDialog(BuildContext context) async {
  TextEditingController titleController = TextEditingController();
  TextEditingController episodeController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  String selectedCollection = "Default"; // Default value for the dropdown
  String selectedImage = ''; // Placeholder for image input
  DateTime currentDate = DateTime.now(); // Set the current date for dateCreated
  DateTime lastUpdatedDate = DateTime.now(); // Set the current date for lastUpdated

  // Fetch the collections from the provider
  await Provider.of<CollectionProvider>(context, listen: false).fetchCollections();

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
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: "Notes"),
            ),
            SizedBox(height: 10),
            // Dropdown to select a collection from the database
            DropdownButtonFormField<String>(
              value: selectedCollection,
              onChanged: (newValue) {
                selectedCollection = newValue!;
              },
              items: [
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
              final recordProvider = Provider.of<RecordProvider>(context, listen: false);

              // Create a new Record object based on the dialog inputs
              Record newRecord = Record(
                name: titleController.text.isNotEmpty
                    ? titleController.text
                    : "Untitled",
                collection: Collection(
                  name: selectedCollection,
                  type: "", // Adjust as needed
                  season: 1,
                  description: "", // You can add more fields here if necessary
                ),
                episode: int.tryParse(episodeController.text) ?? 1,
                notes: notesController.text, // Add notes from input field
                image: selectedImage, // Image should be handled dynamically
                dateCreated: currentDate,
                lastUpdated: lastUpdatedDate,
                timestamps: [], // Add any timestamps logic if needed
              );

              // Add the new record to the record provider
              recordProvider.addRecord(newRecord);

              // Close the dialog
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
                                // Navigate to CollectionInfoScreen with the collection details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CollectionInfoScreen(
                                          collection:
                                              collection, // Pass the selected collection
                                        ),
                                  ),
                                );
                              },

                              child: Card(
                                elevation: 5, // Add elevation if needed
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      // Shadow on the left and top
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          0.2,
                                        ), // Adjust opacity as needed
                                        offset: Offset(-3, -3),
                                        blurRadius: 6,
                                      ),
                                      // Shadow on the right and bottom
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
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
                    print('Settings pressed');
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
