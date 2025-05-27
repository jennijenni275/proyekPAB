import 'dart:convert';
import 'dart:typed_data'; // Pastikan ini diimpor
import 'package:flutter/material.dart';
import 'package:museglo/model/favorite_storage.dart';
import 'package:museglo/model/MuseumModel.dart';

class DetailScreen extends StatefulWidget {
  final Museum museum;

  const DetailScreen({super.key, required this.museum});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Debugging awal: cetak data gambar untuk koleksi pertama
    if (widget.museum.collections.isNotEmpty) {
      final initialArtwork = widget.museum.collections[currentIndex];
      String? initialBase64 = initialArtwork.imageBase64;
      print('--- DETAIL SCREEN INIT ---');
      print('Initial artwork title: ${initialArtwork.title}');
      print(
        'Initial artwork base64: ${initialBase64 == null || initialBase64.isEmpty
            ? 'Empty/Null'
            : initialBase64.length < 50
            ? initialBase64
            : initialBase64.substring(0, 50) + '... (length: ${initialBase64.length})'}',
      );
      print(
        'Initial artwork imageUrl: ${initialArtwork.imageUrl.isEmpty ? 'Empty' : initialArtwork.imageUrl}',
      );
      print('--------------------------');
    } else {
      print('--- DETAIL SCREEN INIT: No collections in this museum. ---');
    }
  }

  bool isFavorite(Collection artwork) {
    return FavoriteStorage.favorites.any(
      (item) =>
          item.title == artwork.title &&
          item.artist == artwork.artist &&
          item.year == artwork.year,
    );
  }

  void toggleFavorite() {
    final current = widget.museum.collections[currentIndex];
    final exists = isFavorite(current);

    setState(() {
      if (exists) {
        FavoriteStorage.favorites.removeWhere(
          (item) =>
              item.title == current.title &&
              item.artist == current.artist &&
              item.year == current.year,
        );
      } else {
        FavoriteStorage.favorites.add(current);
      }
    });
  }

  void nextArtwork() {
    if (currentIndex < widget.museum.collections.length - 1) {
      setState(() {
        currentIndex++;
        final currentArtwork = widget.museum.collections[currentIndex];
        String? nextBase64 = currentArtwork.imageBase64;
        print('--- NAVIGATING TO NEXT ARTWORK ---');
        print('Next artwork title: ${currentArtwork.title}');
        print(
          'Next artwork base64: ${nextBase64 == null || nextBase64.isEmpty
              ? 'Empty/Null'
              : nextBase64.length < 50
              ? nextBase64
              : nextBase64.substring(0, 50) + '... (length: ${nextBase64.length})'}',
        );
        print(
          'Next artwork imageUrl: ${currentArtwork.imageUrl.isEmpty ? 'Empty' : currentArtwork.imageUrl}',
        );
        print('----------------------------------');
      });
    }
  }

  void previousArtwork() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        final currentArtwork = widget.museum.collections[currentIndex];
        String? prevBase64 = currentArtwork.imageBase64;
        print('--- NAVIGATING TO PREVIOUS ARTWORK ---');
        print('Previous artwork title: ${currentArtwork.title}');
        print(
          'Previous artwork base64: ${prevBase64 == null || prevBase64.isEmpty
              ? 'Empty/Null'
              : prevBase64.length < 50
              ? prevBase64
              : prevBase64.substring(0, 50) + '... (length: ${prevBase64.length})'}',
        );
        print(
          'Previous artwork imageUrl: ${currentArtwork.imageUrl.isEmpty ? 'Empty' : currentArtwork.imageUrl}',
        );
        print('--------------------------------------');
      });
    }
  }

  // Fungsi untuk memvalidasi string Base64
  // Fungsi ini mengembalikan true jika string dapat didekode Base64, false jika tidak.
  bool isValidBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      print('isValidBase64 check failed for string. Error: $e');
      // Opsional: print sebagian string yang gagal untuk debugging lebih lanjut
      // print('Invalid Base64 string starts with: ${str.length > 50 ? str.substring(0, 50) : str}...');
      return false;
    }
  }

  // Fungsi untuk membangun widget gambar
  Widget buildImage(Collection artwork) {
    String? base64Data = artwork.imageBase64;

    print('--- BUILD IMAGE FOR ${artwork.title} ---');
    if (base64Data != null && base64Data.isNotEmpty) {
      print('Base64 data status: Present. Length: ${base64Data.length}');
      // Mencetak awal string Base64 untuk debugging (aman dari RangeError)
      print(
        'Base64 data starts with: ${base64Data.length < 50 ? base64Data : base64Data.substring(0, 50) + '...'}',
      );

      if (isValidBase64(base64Data)) {
        try {
          Uint8List bytes = base64Decode(base64Data);
          print('Base64 decoded successfully. Displaying Image.memory.');
          return Image.memory(
            bytes,
            height: 250,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Error saat Image.memory mencoba menampilkan bytes (bukan decoding)
              print(
                'ERROR: Image.memory failed to render for ${artwork.title}. Error: $error',
              );
              print('Stack trace (Image.memory): $stackTrace');
              return _fallbackImage(artwork);
            },
          );
        } catch (e) {
          // Error saat base64Decode gagal (walaupun isValidBase64 sudah dicek, ini sebagai fallback)
          print(
            'ERROR: Exception during base64Decode for ${artwork.title}. Error: $e',
          );
          return _fallbackImage(artwork);
        }
      } else {
        print(
          'Base64 data is NOT valid according to isValidBase64 for ${artwork.title}.',
        );
        return _fallbackImage(artwork);
      }
    } else {
      print(
        'Base64 data is null or empty for ${artwork.title}. Trying imageUrl fallback.',
      );
      return _fallbackImage(artwork);
    }
  }

  // Fungsi fallback jika Base64 tidak tersedia atau bermasalah
  Widget _fallbackImage(Collection artwork) {
    if (artwork.imageUrl.isNotEmpty) {
      print('Attempting to load image from URL: ${artwork.imageUrl}');
      return Image.network(
        artwork.imageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Error saat Image.network gagal memuat dari URL
          print(
            'ERROR: Image.network failed to load for ${artwork.title}. URL: ${artwork.imageUrl}. Error: $error',
          );
          print('Stack trace (Image.network): $stackTrace');
          return _placeholderImage();
        },
      );
    } else {
      print(
        'No valid Base64 or URL found for ${artwork.title}. Showing placeholder.',
      );
      return _placeholderImage();
    }
  }

  // Fungsi untuk menampilkan placeholder "Gambar tidak tersedia"
  Widget _placeholderImage() {
    print('Displaying "Gambar tidak tersedia" placeholder.');
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(child: Text('Gambar tidak tersedia')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.museum.collections.isEmpty) {
      print(
        'Museum has no collections. Displaying "Tidak ada koleksi" message.',
      );
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
    final isFav = isFavorite(artwork);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.museum.name),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
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
                      child: buildImage(
                        artwork,
                      ), // Ini memanggil fungsi buildImage
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: toggleFavorite,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
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
                        'Title: ${artwork.title}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Artist: ${artwork.artist}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Year: ${artwork.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artwork.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
