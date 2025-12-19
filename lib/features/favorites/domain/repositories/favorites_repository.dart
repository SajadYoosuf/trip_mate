import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

abstract class FavoritesRepository {
  Future<List<Place>> getFavorites();
  Future<void> addFavorite(Place place);
  Future<void> removeFavorite(String placeId);
  Future<bool> isFavorite(String placeId);
}
