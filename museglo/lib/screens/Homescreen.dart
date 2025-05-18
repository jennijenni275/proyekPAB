import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:museglo/screens/post_screen.dart';
import 'package:museglo/screens/profile_screen.dart';
import 'package:museglo/screens/search_screen.dart';
import 'package:museglo/screens/detail_screen.dart';
import 'package:museglo/model/MuseumModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
} //harusnya udah

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Tidak ada data museum'));
          }

          final data = snapshot.data!.snapshot.value as Map;

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                data.entries.map((entry) {
                  final museum = Museum.fromMap(
                    Map<String, dynamic>.from(entry.value),
                  );

                  return MuseumCard(
                    name: museum.name,
                    description:
                        museum.collections.isNotEmpty
                            ? museum.collections[0].description
                            : 'Deskripsi tidak tersedia',
                    address: museum.location,
                    artworks: museum.collections.length,
                    imageUrl:
                        museum.collections.isNotEmpty
                            ? museum.collections[0].imageUrl
                            : '',
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
                }).toList(),
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
