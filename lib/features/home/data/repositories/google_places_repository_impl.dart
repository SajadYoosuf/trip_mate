
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temporal_zodiac/core/constants/api_constants.dart';
import 'package:temporal_zodiac/features/home/data/models/place_model.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/places_repository.dart';

class GooglePlacesRepositoryImpl implements PlacesRepository {
  @override
  Future<List<Place>> searchPlaces(String textQuery) async {
    final url = Uri.parse(ApiConstants.googlePlacesBaseUrl);
    
    // Headers as specified in the request
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiConstants.googlePlacesApiKey,
      'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.priceLevel,places.photos,places.currentOpeningHours,places.nationalPhoneNumber,places.regularOpeningHours,places.rating,places.location',
    };

    final body = jsonEncode({
      'textQuery': textQuery,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final placesList = data['places'] as List<dynamic>?;

        if (placesList != null) {
          return placesList
              .map<Place>((json) => PlaceModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }
}
