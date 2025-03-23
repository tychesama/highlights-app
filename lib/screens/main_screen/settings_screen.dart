import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/record_provider.dart';
import '../../providers/collection_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _updateTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }

  void _showRecords() {
    final recordProvider = Provider.of<RecordProvider>(context, listen: false);
    final records = recordProvider.getAllRecords();

    for (var record in records) {
      print("Record: ${record.name}, Episode: ${record.episode}, Notes: ${record.notes}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Records printed to console")),
    );
  }

  Future<void> _showCollections() async {
    final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
    final collections = await collectionProvider.fetchCollections();

    for (var collection in collections) {
      print("Collection: ${collection.name}, Type: ${collection.type}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Collections printed to console")),
    );
  }

  Future<void> _clearRecords() async {
    final recordProvider = Provider.of<RecordProvider>(context, listen: false);
    await recordProvider.clearAllRecords();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All records cleared!")),
    );
  }

  Future<void> _clearAllData() async {
    final recordProvider = Provider.of<RecordProvider>(context, listen: false);
    final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);

    await recordProvider.clearAllRecords();
    await collectionProvider.clearAllCollections();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All records and collections deleted!")),
    );
  }

  void _openImportExportScreen() {
    // Navigate to Import/Export Management screen (to be implemented)
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Highlights",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2025 Highlights App",
    );
  }

  void _openHelp() {
    // Implement Help screen navigation
  }

  void _openContactUs() {
    // Implement Contact Us screen navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          // Logo Section (30% of screen height)
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            alignment: Alignment.center,
            child: Icon(Icons.settings, size: 120, color: Colors.orange),
          ),

          // Settings List
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("Show Records"),
                  trailing: Icon(Icons.list, color: Colors.blue),
                  onTap: _showRecords,
                ),
                ListTile(
                  title: Text("Show Collections"),
                  trailing: Icon(Icons.folder, color: Colors.green),
                  onTap: _showCollections,
                ),
                ListTile(
                  title: Text("Import / Export Management"),
                  trailing: Icon(Icons.import_export, color: Colors.purple),
                  onTap: _openImportExportScreen,
                ),
                SwitchListTile(
                  title: Text("Choose Theme"),
                  value: _darkMode,
                  onChanged: _updateTheme,
                ),
                Divider(), // Separates data options from help & about

                ListTile(
                  title: Text("Delete Records"),
                  trailing: Icon(Icons.delete, color: Colors.red),
                  onTap: _clearRecords,
                ),
                ListTile(
                  title: Text("Delete All Data"),
                  trailing: Icon(Icons.warning, color: Colors.redAccent),
                  onTap: _clearAllData,
                ),
                Divider(),

                ListTile(
                  title: Text("Help"),
                  trailing: Icon(Icons.help, color: Colors.blueGrey),
                  onTap: _openHelp,
                ),
                ListTile(
                  title: Text("Contact Us"),
                  trailing: Icon(Icons.contact_mail, color: Colors.teal),
                  onTap: _openContactUs,
                ),
                ListTile(
                  title: Text("About"),
                  trailing: Icon(Icons.info, color: Colors.deepPurple),
                  onTap: _showAboutDialog,
                ),
                ListTile(
                  title: Text("Version 1.0.0"),
                  trailing: Icon(Icons.verified, color: Colors.green),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
