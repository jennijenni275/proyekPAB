import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        backgroundColor: Colors.grey[300],
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          FavoriteItem(
            imageUrl: 'https://placehold.co/100x100',
            title: 'The Happy Accidents of the Swing',
          ),
          FavoriteItem(
            imageUrl: 'https://placehold.co/100x100',
            title: 'Keris dhapur Kebo Lajer, pamor tambal',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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

class FavoriteItem extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FavoriteItem({
    required this.imageUrl,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
  leading: Icon(Icons.favorite, color: Theme.of(context).iconTheme.color),
  title: Text('Favorite', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
        ),
      ),
    );
  }
}
