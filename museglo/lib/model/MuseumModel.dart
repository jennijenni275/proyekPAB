class Collection {
  final String title;
  final String artist;
  final String year;
  final String description;
  final String imageUrl;

  Collection({
    required this.title,
    required this.artist,
    required this.year,
    required this.description,
    required this.imageUrl,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      year: map['year'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
}

class Museum {
  final String name;
  final String location;
  final String mapsUrl;
  final String openHours;
  final List<Collection> collections;

  Museum({
    required this.name,
    required this.location,
    required this.mapsUrl,
    required this.openHours,
    required this.collections,
  });

  factory Museum.fromMap(Map<String, dynamic> map) {
    var collectionsFromMap = <Collection>[];
    if (map['collections'] != null) {
      collectionsFromMap =
          List<Map<String, dynamic>>.from(
            map['collections'],
          ).map((item) => Collection.fromMap(item)).toList();
    }

    return Museum(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      mapsUrl: map['maps_url'] ?? '',
      openHours: map['open_hours'] ?? '',
      collections: collectionsFromMap,
    );
  }
}
