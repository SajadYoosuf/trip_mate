import 'package:hive/hive.dart';
import 'package:temporal_zodiac/models/place_hive_model.dart';
import 'package:temporal_zodiac/services/favorites/recents_repository.dart';
import 'package:temporal_zodiac/models/place.dart';

class RecentsRepositoryImpl implements RecentsRepository {
  final Box<PlaceHiveModel> _box;

  RecentsRepositoryImpl(this._box);

  @override
  Future<List<Place>> getRecents() async {
    // Return reversed so latest is first
    return _box.values.toList().reversed.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addRecent(Place place) async {
    final hiveModel = PlaceHiveModel.fromEntity(place);
    // Remove if exists to move to top
    if (_box.containsKey(place.id)) {
      await _box.delete(place.id);
    }
    await _box.put(place.id, hiveModel);
    
    // Limit to 20? 
    if (_box.length > 20) {
      await _box.deleteAt(0); // Delete oldest (first key)
    }
  }
}
