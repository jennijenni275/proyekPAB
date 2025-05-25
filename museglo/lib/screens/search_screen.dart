import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:museglo/screens/collectionsscreen.dart';
import 'package:museglo/screens/detail_screen.dart'; // pastikan ini menerima data koleksi

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCollections = [];
  List<Map<String, dynamic>> _filteredCollections = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  Future<void> _fetchCollections() async {
    final ref = FirebaseDatabase.instance.ref().child('museums');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> loaded = [];

      for (var museumEntry in snapshot.children) {
        final museumData = museumEntry.value as Map<dynamic, dynamic>;
        final museumName = museumData['name'] ?? 'Unknown';

        if (museumData['collections'] != null) {
          final collections = List.from(museumData['collections']);
          for (var item in collections) {
            loaded.add({
              'title': item['title'] ?? '',
              'artist': item['artist'] ?? '',
              'year': item['year'] ?? '',
              'description': item['description'] ?? '',
              'image_url': item['image_url'] ?? '',
              'museum': museumName,
            });
          }
        }
      }

      setState(() {
        _allCollections = loaded;
      });
    }
  }

  void _searchCollections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _hasSearched = true;
      _filteredCollections =
          _allCollections.where((item) {
            return item['title'].toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Collections',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search exhibit title...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                      ),
                      onSubmitted: (_) => _searchCollections(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.orange),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _filteredCollections.clear();
                        _hasSearched = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  !_hasSearched
                      ? Center(
                        child: Text(
                          'Start typing to search...',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      )
                      : _filteredCollections.isEmpty
                      ? Center(
                        child: Text(
                          'No collections found.',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredCollections.length,
                        itemBuilder: (context, index) {
                          final item = _filteredCollections[index];
                          return Card(
                            color:
                                isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.grey[100],
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading:
                                  item['image_url'] != null &&
                                          item['image_url'] != ''
                                      ? Image.network(
                                        item['image_url'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                      : Icon(
                                        Icons.image,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item['artist']} • ${item['year']} • ${item['museum']}',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CollectionDetailScreen(
                                          collection: item,
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
      ),
    );
  }
}
