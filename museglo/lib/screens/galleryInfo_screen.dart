import 'package:flutter/material.dart';

class GalleryInfoScreen extends StatelessWidget {
  const GalleryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final textColor = isDark ? Colors.white : Colors.black;
    final accentColor = const Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'About MuseGlo',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 340,
          height: 580,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
            ],
          ),
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(8),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildInfoCard(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  content:
                      'MuseGlo adalah aplikasi edukatif dan informatif yang memungkinkan pengguna untuk menjelajahi koleksi seni dari berbagai museum di dunia. Aplikasi ini dibuat sebagai bagian dari proyek mata kuliah untuk memberikan pengalaman budaya digital yang mudah diakses.',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                buildInfoCard(
                  icon: Icons.date_range,
                  title: 'Tanggal Pembuatan',
                  content: 'Aplikasi ini dikembangkan pada Mei 2025.',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                buildInfoCard(
                  icon: Icons.group,
                  title: 'Dibuat Oleh',
                  content:
                      'Femmy Johan, Jennifer Verty, dan Syalsabilla Valentisyesa — Mahasiswa Informatika Universitas Multi Data Palembang.',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                buildInfoCard(
                  icon: Icons.design_services,
                  title: 'Desain & Fitur',
                  content:
                      'Tampilan mendukung mode terang dan gelap, dilengkapi navigasi modern, informasi koleksi museum, fitur favorit, serta kemampuan mengunggah koleksi baru.',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                buildInfoCard(
                  icon: Icons.public,
                  title: 'Tujuan Pengembangan',
                  content:
                      'Meningkatkan literasi budaya masyarakat dan memberikan sarana pembelajaran interaktif tentang seni dan sejarah dunia.',
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color? cardColor,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
