import 'package:flutter/foundation.dart';
import 'package:temporal_zodiac/features/favorites/domain/repositories/visited_repository.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

class VisitedProvider extends ChangeNotifier {
  final VisitedRepository _repository;
  List<Place> _visitedPlaces = [];

  VisitedProvider(this._repository) {
    loadVisitedPlaces();
  }

  List<Place> get visitedPlaces => _visitedPlaces;

  Future<void> loadVisitedPlaces() async {
    _visitedPlaces = await _repository.getVisitedPlaces();
    notifyListeners();
  }

  Future<void> toggleVisited(Place place) async {
    if (isVisited(place.id)) {
      await _repository.removeVisitedPlace(place.id);
      _visitedPlaces.removeWhere((element) => element.id == place.id);
    } else {
      await _repository.addVisitedPlace(place);
      _visitedPlaces.add(place);
    }
    notifyListeners();
  }

  bool isVisited(String placeId) {
    return _visitedPlaces.any((element) => element.id == placeId);
  }
}
