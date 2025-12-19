import 'package:flutter/material.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/place_repository.dart';

class HomeProvider extends ChangeNotifier {
  final PlaceRepository repository;

  HomeProvider({required this.repository});

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
      final results = await Future.wait([
        repository.getNearbyPlaces(),
        repository.getPopularPlaces(),
      ]);

      _nearbyPlaces = results[0];
      _popularPlaces = results[1];
    } catch (e) {
      _error = "Failed to load places";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
