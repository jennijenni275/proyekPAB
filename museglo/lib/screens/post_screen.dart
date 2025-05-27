import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  String? _imageBase64;
  String? _imageUrl;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _isPosting = false;
  bool _isPosted = false;

  String? _selectedMuseumId;
  List<Map<String, dynamic>> _museums = [];

  int _currentIndex = 2;

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
          snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc.data()['name'] ?? 'Museum Tanpa Nama',
            };
          }).toList();

      if (_museums.isNotEmpty) {
        _selectedMuseumId = _museums.first['id'];
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _postImage() async {
    if (_imageBase64 == null ||
        _descController.text.trim().isEmpty ||
        _selectedMuseumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan pilih gambar!')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
      _isPosted = false;
    });

    try {
      final museumRef = FirebaseFirestore.instance
          .collection('museums')
          .doc(_selectedMuseumId);

      await museumRef.collection('collections').add({
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
        'imageBase64': _imageBase64 ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      });

      setState(() {
        _isPosted = true;
        _imageBase64 = null;
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
        MaterialPageRoute(builder: (_) => const SearchingPage()),
      );
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
    final bgColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900] : Colors.white.withOpacity(0.9);
    final textColor = isDark ? Colors.white : Colors.black;

    final isPostEnabled =
        _imageBase64 != null &&
        _descController.text.trim().isNotEmpty &&
        !_isPosting &&
        _selectedMuseumId != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Post Image', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMuseumId,
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: cardColor,
              style: TextStyle(color: textColor),
              items:
                  _museums.map<DropdownMenuItem<String>>((museum) {
                    return DropdownMenuItem<String>(
                      value: museum['id'] as String,
                      child: Text(
                        museum['name'] as String,
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedMuseumId = value),
            ),
            const SizedBox(height: 12),
            _buildTextField(_titleController, 'Title...', isDark),
            _buildTextField(_artistController, 'Artist...', isDark),
            _buildTextField(
              _yearController,
              'Year...',
              isDark,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[700] : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('+ IMAGE'),
            ),
            const SizedBox(height: 20),
            _imageBase64 != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(_imageBase64!),
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      'No Image Selected',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            _buildTextField(
              _descController,
              'Description...',
              isDark,
              maxLines: null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPostEnabled ? _postImage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPostEnabled ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isPosting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Post', style: TextStyle(fontSize: 16)),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: isDark ? Colors.blue[300] : Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? Colors.black : Colors.grey[200],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType? inputType,
    int? maxLines,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines ?? 1,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
