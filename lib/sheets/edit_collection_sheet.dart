import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:highlight_marker/models/collection.dart';
import 'package:highlight_marker/providers/collection_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditCollectionSheet extends StatefulWidget {
  final Collection collection;

  const EditCollectionSheet({Key? key, required this.collection})
    : super(key: key);

  @override
  _EditCollectionSheetState createState() => _EditCollectionSheetState();
}

class _EditCollectionSheetState extends State<EditCollectionSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  int? _selectedSeason;
  String? _selectedType;
  String? _thumbnailPath;

  List<String> types = [
    "Livestream",
    "Anime",
    "Movie",
    "Series",
    "Sports Game",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.collection.name);
    _descriptionController = TextEditingController(
      text: widget.collection.description,
    );
    _selectedSeason = widget.collection.season;
    _selectedType = widget.collection.type;
    _thumbnailPath = widget.collection.thumbnail;
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _thumbnailPath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updatedCollection = widget.collection.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      season: _selectedSeason,
      type: _selectedType,
      thumbnail: _thumbnailPath,
      lastUpdated: DateTime.now(),
    );

    await Provider.of<CollectionProvider>(
      context,
      listen: false,
    ).updateCollection(updatedCollection);

    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection successfully updated.'),
            duration: Duration(seconds: 2),
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Collection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(labelText: 'Season'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedSeason = int.tryParse(value);
                });
              },
            ),

            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(labelText: 'Type'),
              items:
                  types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                GestureDetector(
                  onTap: _pickThumbnail,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                    ), 
                    child: Container(
                      width: 150, 
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        image:
                            _thumbnailPath != null
                                ? DecorationImage(
                                  image: FileImage(File(_thumbnailPath!)),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          _thumbnailPath == null
                              ? Center(
                                child: Text(
                                  "Add Thumbnail",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ) 
                              : null,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            ElevatedButton(onPressed: _saveChanges, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
