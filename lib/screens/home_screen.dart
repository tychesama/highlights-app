import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../models/record.dart';
import '../models/type.dart';
import 'record_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showNewRecordDialog() {
    TextEditingController titleController = TextEditingController();
    String selectedOption = "Anime"; // Default value
    List<String> options = ["Anime", "Movie", "Series", "Others"];

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
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedOption,
                onChanged: (newValue) {
                  setState(() {
                    selectedOption = newValue!;
                  });
                },
                items:
                    options.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                decoration: InputDecoration(labelText: "Select Category"),
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

                Type selectedType;
                switch (selectedOption) {
                  case "Anime":
                    selectedType = Anime(
                      title:
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : "Untitled",
                      season: 1,
                      episode: 1,
                      description: "",
                    );
                    break;
                  case "Movie":
                    selectedType = Movie(
                      title:
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : "Untitled",
                      description: "",
                    );
                    break;
                  case "Series":
                    selectedType = Series(
                      title:
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : "Untitled",
                      season: 1,
                      episode: 1,
                      description: "",
                    );
                    break;
                  case "Stream":
                    selectedType = Stream(
                      title:
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : "Untitled",
                      description: "",
                    );
                    break;
                  default:
                    selectedType = Others(
                      title:
                          titleController.text.isNotEmpty
                              ? titleController.text
                              : "Untitled",
                      description: "",
                    );
                }

                // Create new record
                Record newRecord = Record(
                  name:
                      titleController.text.isNotEmpty
                          ? titleController.text
                          : "Untitled",
                  type: selectedType,
                );

                // Add record to provider
                recordProvider.addRecord(newRecord);
                Navigator.pop(context); // Close the dialog
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
          // Categories Section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Category",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // PRssss
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Card(
                          child: SizedBox(
                            width: 150,
                            child: Center(child: Text("Category ${index + 1}")),
                          ),
                        ),
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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall,
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

      // body: Consumer<RecordProvider>(
      //   builder: (context, recordProvider, child) {
      //     return ListView.builder(
      //       itemCount: recordProvider.records.length,
      //       itemBuilder: (context, index) {
      //         final record = recordProvider.records[index];
      //         return ListTile(
      //           title: Text(record.name),
      //           subtitle: Text("Created: ${record.dateCreated}"),
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => RecordScreen(record: record),
      //               ),
      //             );
      //           },
      //         );
      //       },
      //     );
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewRecordDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
