import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/place_repository.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/places_repository.dart';

class HomeProvider extends ChangeNotifier {
  final PlaceRepository repository;
  final PlacesRepository googlePlacesRepository;

  HomeProvider({
    required this.repository,
    required this.googlePlacesRepository,
  });

  List<Place> _nearbyPlaces = [];
  List<Place> _popularPlaces = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get nearbyPlaces => _nearbyPlaces;
  List<Place> get popularPlaces => _popularPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch mock popular places
      final popularFuture = repository.getPopularPlaces();
      
      // Fetch live nearby places
      List<Place> livePlaces = [];
      try {
        livePlaces = await _fetchLivePlaces();
      } catch (e) {
        debugPrint('Error fetching live places: $e');
        // Fallback to mock if live fails
        livePlaces = await repository.getNearbyPlaces();
      }

      _popularPlaces = await popularFuture;
      _nearbyPlaces = livePlaces;

    } catch (e) {
      _error = "Failed to load places";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Place>> _fetchLivePlaces() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    
    // Get City Name
    String city = 'India'; // Default
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'India';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    final query = "Mountains and forest and rivers and parks, $city";
    return await googlePlacesRepository.searchPlaces(query);
  }
}
