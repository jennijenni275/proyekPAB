import 'package:flutter/material.dart';
import 'package:museglo/screens/profile_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Simpan status favorite untuk setiap item (bisa pakai id unik jika ada)
  final List<bool> _isFavorited = [false, false];

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
            isFavorited: _isFavorited[0],
            onFavoriteTap: () {
              setState(() {
                _isFavorited[0] = !_isFavorited[0];
              });
            },
          ),
          FavoriteItem(
            imageUrl: 'https://placehold.co/100x100',
            title: 'Keris dhapur Kebo Lajer, pamor tambal',
            isFavorited: _isFavorited[1],
            onFavoriteTap: () {
              setState(() {
                _isFavorited[1] = !_isFavorited[1];
              });
            },
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
  final bool isFavorited;
  final VoidCallback onFavoriteTap;

  const FavoriteItem({
    required this.imageUrl,
    required this.title,
    required this.isFavorited,
    required this.onFavoriteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Image.network(
            imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite,
            color: isFavorited ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteTap,
        ),
      ),
    );
  }
}