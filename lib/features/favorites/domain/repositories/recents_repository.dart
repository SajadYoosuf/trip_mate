import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

abstract class RecentsRepository {
  Future<List<Place>> getRecents();
  Future<void> addRecent(Place place);
}
