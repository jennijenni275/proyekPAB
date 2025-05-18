import 'package:firebase_database/firebase_database.dart';
import '../model/MuseumModel.dart';

class FirebaseService {
  static Future<List<Museum>> fetchMuseums() async {
    final ref = FirebaseDatabase.instance.ref('museums');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map museumMap = snapshot.value as Map;
      final List<Museum> museumList = [];

      museumMap.forEach((key, value) {
        museumList.add(Museum.fromMap(Map<String, dynamic>.from(value)));
      });

      return museumList;
    } else {
      return [];
    }
  }
}
