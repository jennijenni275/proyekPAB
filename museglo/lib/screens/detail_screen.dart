import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> collections;

  const DetailScreen({super.key, required this.collections});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int currentIndex = 0;

  void nextArtwork() {
    setState(() {
      if (currentIndex < widget.collections.length - 1) {
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
    final artwork = widget.collections[currentIndex];
    final title = artwork['title'] ?? 'Unknown Title';
    final artist = artwork['artist'] ?? 'Unknown Artist';
    final year = artwork['year']?.toString() ?? '-';
    final description = artwork['description'] ?? 'No description';
    final imageUrl =
        artwork['image_url'] ??
        'https://placehold.co/300x400/EEE/31343C?text=No+Image';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Karya Seni'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Gambar tidak tersedia'),
                        ),
                      );
                    },
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
              if (currentIndex < widget.collections.length - 1)
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Artist: $artist',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Year: $year', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
