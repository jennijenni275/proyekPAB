import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:museglo/screens/detail_screen.dart';
import 'package:museglo/screens/post_screen.dart';
import 'package:museglo/screens/profile_screen.dart';
import 'package:museglo/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchingPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostImagePage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MuseGlo'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<DatabaseEvent>(
        future: FirebaseDatabase.instance.ref('museums').once(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan: Tidak dapat memuat data.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text('Tidak ada museum yang ditemukan.'),
            );
          }

          final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final museumList = data.entries.toList();

          return ListView.builder(
            itemCount: museumList.length,
            itemBuilder: (context, index) {
              final museumData = Map<String, dynamic>.from(
                museumList[index].value,
              );
              final name = museumData['name'] ?? 'Museum Tidak Dikenal';
              final description =
                  museumData['description'] ?? 'Deskripsi tidak ada';
              final address = museumData['address'] ?? 'Alamat tidak ditemukan';
              final imageUrl =
                  museumData['image_url'] ??
                  'https://placehold.co/200x150/EEE/31343C?text=Gambar';
              final mapUrl = museumData['map_url'] ?? '';
              final collections =
                  (museumData['collections'] as List<dynamic>?)
                      ?.map((item) => Map<String, dynamic>.from(item))
                      .toList() ??
                  [];
              final artworks = collections.length;

              return MuseumCard(
                name: name,
                description: description,
                address: address,
                artworks: artworks,
                imageUrl: imageUrl,
                mapUrl: mapUrl,
                onTapDetail: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(collections: collections),
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

  Future<void> _launchMapUrl(BuildContext context) async {
    if (mapUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Link peta tidak tersedia')));
      return;
    }

    final uri = Uri.parse(mapUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka peta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTapDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Tidak ada Gambar')),
                      );
                    },
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Ketuk untuk melihat detail museum'),
              ),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'Alamat: $address',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Jumlah koleksi: $artworks',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Lihat di Peta'),
                  onPressed: () => _launchMapUrl(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
