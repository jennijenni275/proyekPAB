import 'package:flutter/material.dart';

class SearchingPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _exhibitController = TextEditingController();

  SearchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // agar keyboard tidak memotong layout
      body: Stack(
        children: [
          // 🔳 Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"), // Ganti dengan path sesuai aset
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔲 Konten utama
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔍 Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Searching...',
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        suffixIcon: Icon(Icons.close, color: Colors.orange),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // 🏷️ Exhibit Name Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _exhibitController,
                            decoration: InputDecoration(
                              hintText: 'Exhibit Name',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 📷 Gambar atau Upload Tombol (placeholder)
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 40),
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
