import 'package:temporal_zodiac/models/place.dart';

abstract class RecentsRepository {
  Future<List<Place>> getRecents();
  Future<void> addRecent(Place place);
}
