import 'package:hive_flutter/hive_flutter.dart';
import 'package:temporal_zodiac/models/place_hive_model.dart';
import 'package:temporal_zodiac/services/favorites/favorites_repository.dart';
import 'package:temporal_zodiac/models/place.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final Box<PlaceHiveModel> _box;

  FavoritesRepositoryImpl(this._box);

  @override
  Future<List<Place>> getFavorites() async {
    return _box.values.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addFavorite(Place place) async {
    final hiveModel = PlaceHiveModel.fromEntity(place);
    await _box.put(place.id, hiveModel);
  }

  @override
  Future<void> removeFavorite(String placeId) async {
    await _box.delete(placeId);
  }

  @override
  Future<bool> isFavorite(String placeId) async {
    return _box.containsKey(placeId);
  }
}
