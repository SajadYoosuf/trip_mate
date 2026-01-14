import 'package:flutter/material.dart';
import 'package:temporal_zodiac/services/favorites/favorites_repository.dart';
import 'package:temporal_zodiac/models/place.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository repository;

  FavoritesProvider({required this.repository});

  List<Place> _favorites = [];
  List<Place> get favorites => _favorites;

  Future<void> loadFavorites() async {
    _favorites = await repository.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Place place) async {
    final isFav = await repository.isFavorite(place.id);
    if (isFav) {
      await repository.removeFavorite(place.id);
    } else {
      await repository.addFavorite(place);
    }
    await loadFavorites();
  }

  bool isFavorite(String placeId) {
    return _favorites.any((element) => element.id == placeId);
  }
}
