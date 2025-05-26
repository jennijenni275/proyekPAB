class Collection {
  final String title;
  final String artist;
  final String year;
  final String description;
  final String imageUrl;
  final String imageBase64;

  Collection({
    required this.title,
    required this.artist,
    required this.year,
    required this.description,
    required this.imageUrl,
    required this.imageBase64,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      year: map['year'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      imageBase64: map['image_base64'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'description': description,
      'image_url': imageUrl,
      'image_base64': imageBase64,
    };
  }
}

class Museum {
  final String name;
  final String imgMuseum;
  final String location;
  final String mapsUrl;
  final String openHours;
  final List<Collection> collections;

  Museum({
    required this.name,
    required this.imgMuseum,
    required this.location,
    required this.mapsUrl,
    required this.openHours,
    required this.collections,
  });

  factory Museum.fromMap(Map<String, dynamic> map) {
    var collectionList = <Collection>[];
    if (map['collections'] != null && map['collections'] is List) {
      collectionList =
          (map['collections'] as List)
              .map(
                (item) => Collection.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList();
    }

    return Museum(
      name: map['name'] ?? '',
      imgMuseum: map['img_museum'] ?? '',
      location: map['location'] ?? '',
      mapsUrl: map['maps_url'] ?? '',
      openHours: map['open_hours'] ?? '',
      collections: collectionList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'img_museum': imgMuseum,
      'location': location,
      'maps_url': mapsUrl,
      'open_hours': openHours,
      'collections': collections.map((c) => c.toMap()).toList(),
    };
  }
}
