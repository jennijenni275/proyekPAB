import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:museglo/model/MuseumModel.dart';
import 'package:museglo/screens/detail_screen.dart';
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Museum> museumList = [];
  List<Collection> searchResultsCollections = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMuseums();
  }

  Future<void> fetchMuseums() async {
    final ref = FirebaseDatabase.instance.ref().child('museums');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<Museum> loadedMuseums = [];
      for (final child in snapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        final museum = Museum.fromMap(data);
        loadedMuseums.add(museum);
      }
      setState(() {
        museumList = loadedMuseums;
        // semua koleksi dari semua museum
        searchResultsCollections =
            loadedMuseums.expand((m) => m.collections).toList();
      });
    }
  }

  void updateSearchResults(String query) {
    if (query.isEmpty) {
      final allCollections = museumList.expand((m) => m.collections).toList();
      setState(() {
        searchResultsCollections = allCollections;
      });
      return;
    }

    final filteredCollections =
        museumList
            .expand((museum) => museum.collections)
            .where(
              (collection) =>
                  collection.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      searchResultsCollections = filteredCollections;
    });
  }

  // Fungsi helper untuk membangun widget gambar dari base64 / url
  Widget _buildCollectionImage(Collection collection) {
    try {
      if (collection.imageBase64.isNotEmpty) {
        // Jika base64 punya prefix "data:image/png;base64," kita hapus dulu
        String base64Str = collection.imageBase64;
        if (base64Str.contains(',')) {
          base64Str = base64Str.split(',').last;
        }
        final bytes = base64Decode(base64Str.trim());
        return Image.memory(
          bytes,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        );
      } else if (collection.imageUrl.isNotEmpty) {
        return Image.network(
          collection.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        );
      } else {
        return const Icon(Icons.image_not_supported);
      }
    } catch (e) {
      // Kalau decode base64 error, tampilkan icon broken image
      print('Error decoding base64 image: $e');
      return const Icon(Icons.broken_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cari Koleksi'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan judul koleksi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: updateSearchResults,
            ),
          ),
          Expanded(
            child:
                searchResultsCollections.isEmpty
                    ? const Center(child: Text('Tidak ada hasil ditemukan'))
                    : ListView.builder(
                      itemCount: searchResultsCollections.length,
                      itemBuilder: (context, index) {
                        final collection = searchResultsCollections[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: _buildCollectionImage(collection),
                            title: Text(collection.title),
                            subtitle: Text(
                              '${collection.artist} (${collection.year})',
                            ),
                            onTap: () {
                              final collection =
                                  searchResultsCollections[index];

                              final dummyMuseum = Museum(
                                name: 'Search Result',
                                location: '',
                                mapsUrl: '',
                                openHours: '',
                                collections: [collection],
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailScreen(
                                        museum: dummyMuseum,
                                        initialIndex: 0, // ini penting!
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
