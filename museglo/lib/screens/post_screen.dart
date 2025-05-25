import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

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
    final snapshot =
        await FirebaseFirestore.instance.collection('museums').get();
    setState(() {
      _museums =
          snapshot.docs
              .map(
                (doc) => {
                  'id': doc.id,
                  'name': doc['name'] ?? 'Museum Tanpa Nama',
                },
              )
              .toList();
      if (_museums.isNotEmpty) {
        _selectedMuseumId = _museums.first['id'];
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _postImage() async {
    if (_image == null ||
        _descController.text.trim().isEmpty ||
        _selectedMuseumId == null)
      return;

    setState(() {
      _isPosting = true;
    });

    try {
      // Convert gambar ke base64
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final ref = FirebaseFirestore.instance
          .collection('museums')
          .doc(_selectedMuseumId);

      await ref.collection('collections').add({
        'title':
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : 'Untitled',
        'artist':
            _artistController.text.trim().isNotEmpty
                ? _artistController.text.trim()
                : FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
        'year':
            _yearController.text.trim().isNotEmpty
                ? _yearController.text.trim()
                : DateTime.now().year.toString(),
        'description': _descController.text.trim(),
        'imageBase64': base64Image,
      });

      setState(() {
        _isPosted = true;
        _image = null;
        _descController.clear();
        _titleController.clear();
        _artistController.clear();
        _yearController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koleksi berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan koleksi: $e')));
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

    final isPostEnabled =
        _image != null &&
        _descController.text.trim().isNotEmpty &&
        !_isPosting &&
        _selectedMuseumId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        title: Text('Post Image', style: TextStyle(color: appBarText)),
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarIcon),
      ),
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          // Overlay (biar konten lebih jelas)
          Container(color: Colors.black.withOpacity(0.3)),
          // Konten utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer supaya gak terlalu ke atas
                  const SizedBox(height: 50),

                  // Dropdown pilih museum
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedMuseumId,
                      isExpanded: true,
                      underline: Container(),
                      hint: const Text('Pilih Museum'),
                      items:
                          _museums
                              .map(
                                (museum) => DropdownMenuItem<String>(
                                  value: museum['id'],
                                  child: Text(museum['name']),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMuseumId = value;
                        });
                      },
                    ),
                  ),

                  // Title input
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Title...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  // Artist input
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _artistController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Artist...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  // Year input
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Year...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('+ IMAGE'),
                  ),
                  const SizedBox(height: 20),

                  _image != null && _image!.existsSync()
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
                        child: const Center(child: Text('No Image Selected')),
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
                        contentPadding: EdgeInsets.all(12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPostEnabled ? _postImage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPostEnabled ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isPosting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Post',
                                style: TextStyle(fontSize: 16),
                              ),
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
                  const SizedBox(height: 40), // Tambah jarak bawah
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
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Post',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
