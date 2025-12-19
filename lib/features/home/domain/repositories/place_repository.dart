import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> getNearbyPlaces();
  Future<List<Place>> getPopularPlaces();
}
