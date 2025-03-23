import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/record.dart';
import '../../models/collection.dart';

class RecordInfoScreen extends StatelessWidget {
  final Record record;
  final Collection? collection;

  const RecordInfoScreen({
    super.key,
    required this.record,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: collection != null &&
                    collection!.thumbnail != null &&
                    collection!.thumbnail!.isNotEmpty
                ? Image.file(
                    File(collection!.thumbnail!),
                    width: 125,
                    height: 130,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white54),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.name.isNotEmpty ? record.name : "Untitled",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (collection != null) ...[
                  Text(
                    'Type: ${collection!.type}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (collection!.season != null && collection!.season != 0)
                    Text(
                      'Season: ${collection!.season}',
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
                Text(
                  'Episode: ${record.episode ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Duration: ${'--:--'}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  record.notes?.isNotEmpty == true
                      ? record.notes!
                      : 'No description',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${record.dateCreated.toLocal().toString().split(" ").first}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
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
