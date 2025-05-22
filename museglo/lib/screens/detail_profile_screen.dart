import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final boxColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Profil'),
        backgroundColor: boxColor,
        centerTitle: true,
        foregroundColor: textColor,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 100, color: Colors.grey[500]),
                const SizedBox(height: 16),
                DetailProfileField(
                  label: 'Username',
                  value: user?.displayName ?? 'Tidak diketahui',
                  boxColor: boxColor!,
                  textColor: textColor,
                ),
                DetailProfileField(
                  label: 'Email',
                  value: user?.email ?? 'Tidak diketahui',
                  boxColor: boxColor!,
                  textColor: textColor,
                ),
                DetailProfileField(
                  label: 'Phone',
                  value: user?.phoneNumber ?? 'Belum ada',
                  boxColor: boxColor!,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).iconTheme.color,
        unselectedItemColor: Theme.of(context).iconTheme.color?.withOpacity(0.5),
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

class DetailProfileField extends StatelessWidget {
  final String label;
  final String value;
  final Color boxColor;
  final Color textColor;

  const DetailProfileField({
    required this.label,
    required this.value,
    required this.boxColor,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}