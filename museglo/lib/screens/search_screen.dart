import 'package:flutter/material.dart';
import 'package:museglo/model/MuseumModel.dart';
import 'package:museglo/screens/detail_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class SearchingPage extends StatefulWidget {
  SearchingPage({super.key});

  @override
  State<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _exhibitController = TextEditingController();
  List<Museum> _allMuseums = [];
  List<Museum> _filteredMuseums = [];

  @override
  void initState() {
    super.initState();
    loadMuseums();
  }

  Future<void> loadMuseums() async {
    final String jsonString = await rootBundle.loadString('lib/model/museums.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    List<Museum> museums = (jsonData['museums'] as List)
        .map((e) => Museum.fromMap(e))
        .toList();
    setState(() {
      _allMuseums = museums;
      _filteredMuseums = museums;
    });
  }

  void _searchMuseums() {
    String query = _searchController.text.toLowerCase();
    String exhibit = _exhibitController.text.toLowerCase();

    setState(() {
      _filteredMuseums = _allMuseums.where((museum) {
        final nameMatch = museum.name.toLowerCase().contains(query);
        final locationMatch = museum.location.toLowerCase().contains(query);
        final exhibitMatch = museum.collections.any((c) =>
            c.title.toLowerCase().contains(exhibit) ||
            c.description.toLowerCase().contains(exhibit));
        return (query.isEmpty || nameMatch || locationMatch) &&
            (exhibit.isEmpty || exhibitMatch);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? Colors.black : Colors.white;
    final appBarText = isDark ? Colors.white : Colors.black;
    final appBarIcon = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Screen',
          style: TextStyle(
            color: appBarText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: IconThemeData(color: appBarIcon),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Searching...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onSubmitted: (_) => _searchMuseums(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.orange),
                          onPressed: _searchMuseums,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.orange),
                          onPressed: () {
                            _searchController.clear();
                            _exhibitController.clear();
                            setState(() => _filteredMuseums = _allMuseums);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Exhibit Name Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _exhibitController,
                            decoration: const InputDecoration(
                              hintText: 'Exhibit Name',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _searchMuseums(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.orange),
                          onPressed: _searchMuseums,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredMuseums.isEmpty
                        ? const Center(child: Text('No museum found'))
                        : ListView.builder(
                            itemCount: _filteredMuseums.length,
                            itemBuilder: (context, index) {
                              final museum = _filteredMuseums[index];
                              return Card(
                                color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.9),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    museum.name,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    museum.location,
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailScreen(museum: museum),
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
          ),
        ],
      ),
    );
  }
}