import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // maps
  void _openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Tidak bisa membuka Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MuseGlo'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('museums').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final museumDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: museumDocs.length,
            itemBuilder: (context, index) {
              var data = museumDocs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Nama Museum';
              final imageUrl = data['image'] ?? '';
              final latitude = data['latitude'] ?? 0.0;
              final longitude = data['longitude'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: Image.network(
                    imageUrl,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(name),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () => _openGoogleMaps(latitude, longitude),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: museumDocs[index].id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
