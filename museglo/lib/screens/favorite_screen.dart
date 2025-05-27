import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:museglo/model/MuseumModel.dart';
import 'package:museglo/model/favorite_storage.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  void _removeFavorite(dynamic collection) {
    setState(() {
      FavoriteStorage.favorites.removeWhere(
        (item) =>
            item.title == collection.title &&
            item.artist == collection.artist &&
            item.year == collection.year,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteStorage.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Collections')),
      body:
          favorites.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final collection = favorites[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading:
                          (collection.imageBase64 != null &&
                                  collection.imageBase64!.isNotEmpty)
                              ? Image.memory(
                                base64Decode(collection.imageBase64!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : (collection.imageUrl.isNotEmpty
                                  ? Image.network(
                                    collection.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : Icon(Icons.image_not_supported)),
                      title: Text(collection.title),
                      subtitle: Text(
                        '${collection.artist} (${collection.year})',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Hapus koleksi dari favorit
                          _removeFavorite(collection);
                        },
                      ),
                      onTap: () {
                        // Dummy museum hanya berisi satu koleksi favorit yang dipilih
                        final dummyMuseum = Museum(
                          name: 'Favorites',
                          location: '',
                          mapsUrl: '',
                          openHours: '',
                          collections: [collection],
                          imgMuseum: '',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailScreen(museum: dummyMuseum),
                          ),
                        ).then((_) {
                          // Jika kembali dari DetailScreen, refresh daftar favorit
                          setState(() {});
                        });
                      },
                    ),
                  );
                },
              ),
    );
  }
}
