import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:museglo/model/MuseumModel.dart';

class DetailScreen extends StatefulWidget {
  final Museum museum;

  const DetailScreen({super.key, required this.museum});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int currentIndex = 0;
  bool isFavorite = false;

  void nextArtwork() {
    setState(() {
      if (currentIndex < widget.museum.collections.length - 1) {
        currentIndex++;
      }
    });
  }

  void previousArtwork() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.museum.collections.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.museum.name),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Tidak ada koleksi pada museum ini',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final artwork = widget.museum.collections[currentIndex];
    final title = artwork.title;
    final artist = artwork.artist;
    final year = artwork.year;
    final description = artwork.description;

    final imageWidget =
        artwork.imageBase64 != null && artwork.imageBase64!.isNotEmpty
            ? Image.memory(
              base64Decode(artwork.imageBase64!),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            )
            : Image.network(
              artwork.imageUrl.isNotEmpty
                  ? artwork.imageUrl
                  : 'https://placehold.co/300x400/EEE/31343C?text=No+Image',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.white,
                  child: const Center(child: Text('Gambar tidak tersedia')),
                );
              },
            );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.museum.name),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
                if (currentIndex > 0)
                  Positioned(
                    left: 10,
                    child: GestureDetector(
                      onTap: previousArtwork,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (currentIndex < widget.museum.collections.length - 1)
                  Positioned(
                    right: 10,
                    child: GestureDetector(
                      onTap: nextArtwork,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artist: $artist',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Year: $year',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
