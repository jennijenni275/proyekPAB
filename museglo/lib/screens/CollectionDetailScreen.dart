import 'dart:convert';
import 'package:flutter/material.dart';

class CollectionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = collection['imageBase64'];
    final imageUrl = collection['image_url'] ?? '';

    // Debug log
    print('DEBUG >> image_url: $imageUrl');
    print('DEBUG >> imageBase64: $imageBase64');

    final imageWidget =
        (imageBase64 != null && imageBase64 != '')
            ? Image.memory(
              base64Decode(imageBase64),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
            : (imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Gambar tidak tersedia')),
                    );
                  },
                )
                : Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(child: Text('No image available')),
                ));

    return Scaffold(
      appBar: AppBar(
        title: Text(collection['title'] ?? 'Detail'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Artist: ${collection['artist']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Year: ${collection['year']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Museum: ${collection['museum']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    collection['description'] ?? '',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
