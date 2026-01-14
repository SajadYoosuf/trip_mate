import 'package:hive/hive.dart';
import 'package:temporal_zodiac/models/place_hive_model.dart';
import 'package:temporal_zodiac/services/favorites/visited_repository.dart';
import 'package:temporal_zodiac/models/place.dart';

class VisitedRepositoryImpl implements VisitedRepository {
  final Box<PlaceHiveModel> _box;

  VisitedRepositoryImpl(this._box);

  @override
  Future<List<Place>> getVisitedPlaces() async {
    return _box.values.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addVisitedPlace(Place place) async {
    await _box.put(place.id, PlaceHiveModel.fromEntity(place));
  }

  @override
  Future<void> removeVisitedPlace(String placeId) async {
    await _box.delete(placeId);
  }

  @override
  Future<bool> isVisited(String placeId) async {
    return _box.containsKey(placeId);
  }
}
