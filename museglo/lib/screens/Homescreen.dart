import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:museglo/screens/post_screen.dart';
import 'package:museglo/screens/profile_screen.dart';
import 'package:museglo/screens/search_screen.dart';
import 'package:museglo/screens/detail_screen.dart';
import 'package:museglo/screens/galleryInfo_screen.dart';
import 'package:museglo/model/MuseumModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        setState(() => _selectedIndex = index);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchingPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostImagePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<List<Museum>> fetchMuseums() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('museums').get();
    List<Museum> museums = [];

    for (var doc in snapshot.docs) {
      var museumData = doc.data();

      final collectionsSnapshot =
          await doc.reference.collection('collections').get();
      List<Collection> collections =
          collectionsSnapshot.docs
              .map((cDoc) => Collection.fromMap(cDoc.data()))
              .toList();

      museums.add(
        Museum(
          name: museumData['name'] ?? '',
          location: museumData['location'] ?? '',
          mapsUrl: museumData['maps_url'] ?? '',
          openHours: museumData['open_hours'] ?? '',
          collections: collections,
          imgMuseum: museumData['img_museum'] ?? '',
        ),
      );
    }

    return museums;
  }

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'museum_images/$fileName.jpg',
      );
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Upload berhasil, URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload gagal: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? Colors.black : Colors.white;
    final appBarIcon = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: appBarIcon),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GalleryInfoScreen()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Museum>>(
        future: fetchMuseums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data museum.'));
          }

          final museums = snapshot.data!;
          return ListView.builder(
            itemCount: museums.length,
            itemBuilder: (context, index) {
              final museum = museums[index];
              final firstCollection =
                  museum.collections.isNotEmpty ? museum.collections[0] : null;

              return MuseumCard(
                name: museum.name,
                description:
                    firstCollection?.description ?? 'Deskripsi tidak tersedia',
                address: museum.location,
                artworks: museum.collections.length,
                imageUrl: museum.imgMuseum, // gunakan gambar utama museum
                mapUrl: museum.mapsUrl,
                onTapDetail: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(museum: museum),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MuseumCard extends StatelessWidget {
  final String name;
  final String description;
  final String address;
  final int artworks;
  final String imageUrl;
  final String mapUrl;
  final VoidCallback onTapDetail;

  const MuseumCard({
    super.key,
    required this.name,
    required this.description,
    required this.address,
    required this.artworks,
    required this.imageUrl,
    required this.mapUrl,
    required this.onTapDetail,
  });

  void _launchMapsUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Tidak dapat membuka URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('📍 $address'),
                Text('🖼️ Karya seni: $artworks'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onTapDetail,
                      child: const Text('Lihat Detail'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => _launchMapsUrl(mapUrl),
                      child: const Text('Lihat di Maps'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
