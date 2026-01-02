
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

abstract class PlacesRepository {
  Future<List<Place>> searchPlaces(String textQuery);
  Future<Place?> getPlaceDetails(String placeId);
}
