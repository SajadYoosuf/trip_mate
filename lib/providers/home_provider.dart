import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:temporal_zodiac/models/place.dart';
import 'package:temporal_zodiac/services/home/places_repository.dart';

class HomeProvider extends ChangeNotifier {
  final PlacesRepository googlePlacesRepository;
  bool _isInitialized = false;

  HomeProvider({
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
  LocationPermission _locationPermission = LocationPermission.unableToDetermine;
  LocationPermission get locationPermission => _locationPermission;

  Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = "Location services are disabled";
      notifyListeners();
      return false;
    }

    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }

    notifyListeners();
    return _locationPermission == LocationPermission.always || 
           _locationPermission == LocationPermission.whileInUse;
  }

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasPermission = await checkAndRequestLocationPermission();
      if (!hasPermission) {
        _error = "Location permission is required to search for nearby places.";
        return;
      }

      // Fetch live nearby places
      _nearbyPlaces = await _fetchLivePlaces();
      _popularPlaces = _nearbyPlaces.reversed.toList(); 
    } catch (e) {
      _error = "Failed to load places: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Place>> _fetchLivePlaces() async {
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
