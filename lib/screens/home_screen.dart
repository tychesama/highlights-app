import 'package:flutter/material.dart';
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
                  items: options.map((option) {
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
                  String finalTitle = titleController.text.isNotEmpty
                      ? titleController.text
                      : "Untitled";

                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordScreen(
                        title: "$finalTitle - $selectedOption",
                      ),
                    ),
                  );
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
      body: Center(
        child: ElevatedButton(
          onPressed: _showNewRecordDialog,
          child: Text("New Record"),
        ),
      ),
    );
  }
}
