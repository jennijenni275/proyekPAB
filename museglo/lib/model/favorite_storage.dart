import 'package:museglo/model/MuseumModel.dart';

class FavoriteStorage {
  static final List<Collection> _favoriteCollections = [];

  static List<Collection> get favorites => _favoriteCollections;

  static bool isFavorite(Collection collection) {
    return _favoriteCollections.any(
      (c) =>
          c.title == collection.title &&
          c.artist == collection.artist &&
          c.year == collection.year,
    );
  }

  static void toggleFavorite(Collection collection) {
    if (isFavorite(collection)) {
      _favoriteCollections.removeWhere(
        (c) =>
            c.title == collection.title &&
            c.artist == collection.artist &&
            c.year == collection.year,
      );
    } else {
      _favoriteCollections.add(collection);
    }
  }
}
