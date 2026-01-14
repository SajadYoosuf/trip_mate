
import 'package:temporal_zodiac/models/place.dart';

abstract class PlacesRepository {
  Future<List<Place>> searchPlaces(String textQuery);
  Future<Place?> getPlaceDetails(String placeId);
}
