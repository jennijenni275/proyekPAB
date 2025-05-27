class Collection {
  final String title;
  final String artist;
  final String year;
  final String description;
  final String imageUrl;
  final String? imageBase64;

  Collection({
    required this.title,
    required this.artist,
    required this.year,
    required this.description,
    required this.imageUrl,
    this.imageBase64,
  });

  factory Collection.fromMap(Map<String, dynamic> map) {
    // Tambahkan debugging prints seperti yang disarankan sebelumnya
    print('--- Parsing Collection from Map ---');
    print('Raw Map for Collection: $map');

    // Coba baca dari kedua kemungkinan nama field
    // Prioritaskan yang tanpa underscore (koleksi baru) karena itu yang ada imageBase64-nya
    String? imageUrl = map['imageUrl'] as String?; // Coba 'imageUrl' (baru)
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl =
          map['image_url'] as String?; // Jika kosong, coba 'image_url' (lama)
    }

    String? imageBase64 =
        map['imageBase64'] as String?; // Coba 'imageBase64' (baru)
    // Untuk imageBase64, tidak perlu fallback ke 'image_base64' karena yang lama tidak punya.
    // Juga, biarkan null jika memang tidak ada, jangan beri default string kosong
    // imageBase64: map['image_base64'] ini tidak perlu lagi jika kita asumsi koleksi baru saja yang punya

    // Debugging print untuk hasil parsing
    print(
      'Parsed imageUrl: ${imageUrl == null || imageUrl.isEmpty ? 'Empty/Null' : imageUrl}',
    );
    print(
      'Parsed imageBase64: ${imageBase64 == null || imageBase64.isEmpty
          ? 'Empty/Null'
          : imageBase64.length < 50
          ? imageBase64
          : imageBase64.substring(0, 50) + '... (length: ${imageBase64.length})'}',
    );
    print('------------------------------------');

    return Collection(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      year: map['year'] ?? '',
      description: map['description'] ?? '',
      imageUrl: imageUrl ?? '', // Beri default string kosong jika tetap null
      imageBase64: imageBase64, // Biarkan null jika tidak ditemukan
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'year': year,
      'description': description,
      // Saat menyimpan, konsisten gunakan nama field yang baru (tanpa underscore)
      'imageUrl': imageUrl,
      if (imageBase64 != null) 'imageBase64': imageBase64,
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
