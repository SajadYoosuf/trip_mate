
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:temporal_zodiac/core/api_constants.dart';
import 'package:temporal_zodiac/models/place_model.dart';
import 'package:temporal_zodiac/models/place.dart';
import 'package:temporal_zodiac/services/home/places_repository.dart';

class GooglePlacesRepositoryImpl implements PlacesRepository {
  @override
  @override
  Future<List<Place>> searchPlaces(String textQuery) async {
    final url = Uri.parse(ApiConstants.googlePlacesBaseUrl);
    
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiConstants.googlePlacesApiKey,
      'X-Goog-FieldMask': 'places.name,places.id,places.displayName,places.formattedAddress,places.priceLevel,places.photos,places.currentOpeningHours,places.nationalPhoneNumber,places.regularOpeningHours,places.rating,places.location,nextPageToken', 
    };

    List<Place> allPlaces = [];
    String? nextPageToken;

    try {
      do {
        final Map<String, dynamic> bodyMap = {
          'textQuery': textQuery,
          'pageSize': 20,
        };
        if (nextPageToken != null) {
          bodyMap['pageToken'] = nextPageToken;
        }

        final response = await http.post(url, headers: headers, body: jsonEncode(bodyMap));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final placesList = data['places'] as List<dynamic>?;
          
          if (placesList != null) {
            allPlaces.addAll(
              placesList.map<Place>((json) => PlaceModel.fromJson(json)).toList()
            );
          }

          nextPageToken = data['nextPageToken'] as String?;
        } else {
          // If a page fails, we stop and return what we have (or throw). 
          // Logging and breaking is safer to preserve partial results.
          break; 
        }
      } while (nextPageToken != null && allPlaces.length < 60);
      
      return allPlaces;
    } catch (e) {
      throw Exception('Error fetching places: $e');
    }
  }

  @override
  Future<Place?> getPlaceDetails(String placeId) async {
    // If ID is likely an address (legacy data) or invalid, just return null or generic place.
    // For Place API v1, ID should be resource name 'places/ID' or just 'ID'.
    // If it is 'places/...' we use it directly as path.
    // If it is raw 'ChIJ...', we construct 'places/ChIJ...'.
    
    String resourceName = placeId;
    if (!placeId.startsWith('places/')) {
       resourceName = 'places/$placeId';
    }

    final url = Uri.parse('https://places.googleapis.com/v1/$resourceName');
    
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiConstants.googlePlacesApiKey,
      'X-Goog-FieldMask': 'name,id,displayName,formattedAddress,priceLevel,photos,currentOpeningHours,nationalPhoneNumber,regularOpeningHours,rating,location', 
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PlaceModel.fromJson(data);
      } else if (response.statusCode == 400 || response.statusCode == 404) {
          // Fallback: It might be a legacy address string. Try search.
          debugPrint("Falling back to search for: $placeId");
          final searchResults = await searchPlaces(placeId);
          if (searchResults.isNotEmpty) {
              return searchResults.first;
          }
          return null;
      } else {
        debugPrint('Failed to get place details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
      return null;
    }
  }}
