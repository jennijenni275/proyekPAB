import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:museglo/screens/Map_screens.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('museums').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan: Tidak dapat memuat data.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Tidak ada museum yang ditemukan.'),
            );
          }

          final museumDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: museumDocs.length,
            itemBuilder: (context, index) {
              final museumData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final name = museumData['name'] ?? 'Museum Tidak Dikenal';
              final imageUrl =
                  museumData['image'] ??
                  'https://placehold.co/200x150/EEE/31343C?text=Gambar';
              final latitude = museumData['latitude'] ?? 0.0;
              final longitude = museumData['longitude'] ?? 0.0;

              return MuseumCard(
                name: name,
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
  final String imageUrl;
  final double latitude;
  final double longitude;

  const MuseumCard({
    super.key,
    required this.name,
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
                    builder:
                        (context) => MapScreen(
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
