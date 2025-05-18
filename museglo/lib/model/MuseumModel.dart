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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'description': description,
      'image_url': imageUrl,
    };
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

    if (map['collections'] != null && map['collections'] is List) {
      collectionsFromMap =
          (map['collections'] as List)
              .map(
                (item) => Collection.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList();
    }

    return Museum(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      mapsUrl: map['maps_url'] ?? '',
      openHours: map['open_hours'] ?? '',
      collections: collectionsFromMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'maps_url': mapsUrl,
      'open_hours': openHours,
      'collections': collections.map((c) => c.toMap()).toList(),
    };
  }
}
