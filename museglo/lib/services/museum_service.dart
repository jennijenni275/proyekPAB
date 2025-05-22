import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:museglo/model/MuseumModel.dart';

class MuseumService {
  static Future<List<Museum>> fetchMuseums() async {
    final museumCollection = FirebaseFirestore.instance.collection('museums');
    final museumSnapshots = await museumCollection.get();

    List<Museum> museums = [];

    for (var doc in museumSnapshots.docs) {
      final museumData = doc.data();
      final collectionsSnapshot =
          await doc.reference.collection('collections').get();

      List<Collection> collections =
          collectionsSnapshot.docs.map((cDoc) {
            return Collection.fromMap(cDoc.data());
          }).toList();

      Museum museum = Museum(
        name: museumData['name'] ?? '',
        location: museumData['location'] ?? '',
        mapsUrl: museumData['maps_url'] ?? '',
        openHours: museumData['open_hours'] ?? '',
        collections: collections,
      );

      museums.add(museum);
    }

    return museums;
  }
}
