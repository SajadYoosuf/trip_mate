import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

abstract class VisitedRepository {
  Future<List<Place>> getVisitedPlaces();
  Future<void> addVisitedPlace(Place place);
  Future<void> removeVisitedPlace(String placeId);
  Future<bool> isVisited(String placeId);
}
