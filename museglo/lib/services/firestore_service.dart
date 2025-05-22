import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:museglo/model/MuseumModel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Museum>> fetchMuseums() async {
    final querySnapshot = await _db.collection('museums').get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Museum.fromMap(data);
    }).toList();
  }
}
