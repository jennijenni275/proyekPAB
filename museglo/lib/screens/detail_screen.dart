import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import carousel_slider

class MapScreen extends StatefulWidget {
  final String museumName;
  final double latitude;
  final double longitude;

  const MapScreen({
    super.key,
    required this.museumName,
    required this.latitude,
    required this.longitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LatLng museumLocation;

  @override
  void initState() {
    super.initState();
    museumLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.museumName),
        backgroundColor: Colors.black,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: museumLocation,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('museumLocation'),
            position: museumLocation,
            infoWindow: InfoWindow(title: widget.museumName),
          ),
        },
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String museumId;

  const DetailScreen({super.key, required this.museumId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Museum'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('museums')
                .doc(widget.museumId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _showErrorDialog(context, 'Terjadi kesalahan: ${snapshot.error}');
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            _showErrorDialog(context, 'Data museum tidak ditemukan.');
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final museumData = snapshot.data!.data() as Map<String, dynamic>;
          final artworks = museumData['artworks'] as List<dynamic>? ?? [];

          if (artworks.isEmpty) {
            return const Center(
              child: Text('Tidak ada karya seni untuk ditampilkan.'),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: artworks.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final artwork = artworks[index] as Map<String, dynamic>;
                  final title = artwork['title'] ?? 'Judul Tidak Tersedia';
                  final artist = artwork['artist'] ?? 'Artis Tidak Diketahui';
                  final description =
                      artwork['description'] ?? 'Deskripsi Tidak Tersedia';
                  final imageUrl =
                      artwork['image'] ??
                      'https://placehold.co/400x300/EEE/31343C?text=No+Image';

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Text('No Image'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Artis: $artist',
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      artworks.map((artwork) {
                        int index = artworks.indexOf(artwork);
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentPageIndex == index
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        );
                      }).toList(),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    if (_currentPageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_currentPageIndex < artworks.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
