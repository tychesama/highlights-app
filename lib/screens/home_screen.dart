import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/record_provider.dart';
import '../models/record.dart';
import '../models/type.dart';
import 'record_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    selectedOption = newValue!;
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
                        season: 1, // Default value
                        episode: 1, // Default value
                        description: "", // Default value
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
                    type: selectedType, // Use the correct subclass
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

    return Scaffold(
      appBar: AppBar(title: Text("Highlights")),
      body: Consumer<RecordProvider>(
        builder: (context, recordProvider, child) {
          return ListView.builder(
            itemCount: recordProvider.records.length,
            itemBuilder: (context, index) {
              final record = recordProvider.records[index];
              return ListTile(
                title: Text(record.name),
                subtitle: Text("Created: ${record.dateCreated}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordScreen(record: record),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewRecordDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
