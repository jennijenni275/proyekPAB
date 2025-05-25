import 'dart:convert';
import 'package:flutter/material.dart';

class CollectionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = collection['imageBase64'];
    final imageUrl = collection['image_url'] ?? '';
    final imageWidget =
        (imageBase64 != null && imageBase64 != '')
            ? Image.memory(
              base64Decode(imageBase64),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
            : Image.network(
              imageUrl.isNotEmpty
                  ? imageUrl
                  : 'https://placehold.co/300x400/EEE/31343C?text=No+Image',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey,
                  child: const Center(child: Text('Gambar tidak tersedia')),
                );
              },
            );

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
