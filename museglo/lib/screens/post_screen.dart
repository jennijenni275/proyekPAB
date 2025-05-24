import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:museglo/screens/Homescreen.dart';
import 'package:museglo/screens/search_screen.dart';
import 'package:museglo/screens/profile_screen.dart';

class PostImagePage extends StatefulWidget {
  const PostImagePage({super.key});

  @override
  _PostImagePageState createState() => _PostImagePageState();
}

class _PostImagePageState extends State<PostImagePage> {
  File? _image;
  final TextEditingController _descController = TextEditingController();
  bool _isPosting = false;
  bool _isPosted = false;

  String? _selectedMuseumId;
  List<Map<String, dynamic>> _museums = [];

  @override
  void initState() {
    super.initState();
    fetchMuseums();
  }

  Future<void> fetchMuseums() async {
    final snapshot = await FirebaseFirestore.instance.collection('museums').get();
    setState(() {
      _museums = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'] ?? 'Museum Tanpa Nama',
              })
          .toList();
      if (_museums.isNotEmpty) {
        _selectedMuseumId = _museums.first['id'];
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _postImage() async {
    if (_image == null || _descController.text.trim().isEmpty || _selectedMuseumId == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      // Simpan gambar ke Firebase Storage (jika ingin upload gambar, tambahkan logika upload dan dapatkan url)
      final ref = FirebaseFirestore.instance.collection('museums').doc(_selectedMuseumId);

      await ref.collection('collections').add({
        'title': 'New Artwork',
        'artist': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
        'year': DateTime.now().year.toString(),
        'description': _descController.text,
        'imageUrl': '', // Tambahkan url gambar jika upload ke Storage
      });

      setState(() {
        _isPosted = true;
        _image = null;
        _descController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koleksi berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan koleksi: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  int _currentIndex = 2;

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SearchingPage()),
      );
    } else if (index == 2) {
      // Stay on Post
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? Colors.black : Colors.white;
    final appBarText = isDark ? Colors.white : Colors.black;
    final appBarIcon = isDark ? Colors.white : Colors.black;

    final isPostEnabled = _image != null &&
        _descController.text.trim().isNotEmpty &&
        !_isPosting &&
        _selectedMuseumId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        title: Text(
          'Post Image',
          style: TextStyle(color: appBarText),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarIcon),
      ),
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay (optional, biar konten lebih jelas)
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Konten utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dropdown pilih museum
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedMuseumId,
                      isExpanded: true,
                      underline: Container(),
                      hint: const Text('Pilih Museum'),
                      items: _museums
                          .map((museum) => DropdownMenuItem<String>(
                                value: museum['id'],
                                child: Text(museum['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMuseumId = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('+ IMAGE'),
                  ),
                  const SizedBox(height: 20),
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('No Image Selected'),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Desc...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPostEnabled ? _postImage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPostEnabled
                            ? Colors.blue
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Post'),
                    ),
                  ),
                  if (_isPosted)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Koleksi berhasil ditambahkan!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}