import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:museglo/screens/Map_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final museumList = data.entries.toList();

          return ListView.builder(
            itemCount: museumList.length,
            itemBuilder: (context, index) {
              final museumData = museumList[index].value as Map<dynamic, dynamic>;
              final name = museumData['name'] ?? 'Museum Tidak Dikenal';
              final description = museumData['description'] ?? 'deskripsi tidak ada';
              final address = museumData['address'] ?? 'Alamat tidak ditemukan';
              final artworks = (museumData['artworks'] ?? 0.0).toDouble();
              final imageUrl = museumData['image'] ?? 'https://placehold.co/200x150/EEE/31343C?text=Gambar';
              final latitude = (museumData['latitude'] ?? 0.0).toDouble();
              final longitude = (museumData['longitude'] ?? 0.0).toDouble();

              return MuseumCard(
                name: name,
                description: description,
                address: address,
                artworks: artworks,
                imageUrl: imageUrl,
                latitude: latitude,
                longitude: longitude,
              );
            },
          );
        },
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
  final double latitude;
  final double longitude;

  const MuseumCard({
    super.key,
    required this.name,
    required this.description,
    required this.address,
    required this.artworks,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              subtitle: const Text('Ketuk untuk melihat di peta'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      museumName: name,
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(name),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(title: name),
                    ),
                  },
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  onMapCreated: (controller) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
