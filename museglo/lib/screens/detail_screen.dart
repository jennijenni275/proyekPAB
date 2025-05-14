import 'package:flutter/material.dart';
import 'package:museglo/screens/detail_profile_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[700],
            child: Column(
              children: [
                const Icon(Icons.account_circle, size: 80, color: Colors.white),
                const SizedBox(height: 8),
                const Text('User', style: TextStyle(color: Colors.white, fontSize: 20)),
                const Text('User@gmail.com', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.perm_identity, color: Colors.white),
            title: const Text('Identitas', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_num, color: Colors.white),
            title: const Text('My Ticket', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.star_border, color: Colors.white),
            title: const Text('Favorites', style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
