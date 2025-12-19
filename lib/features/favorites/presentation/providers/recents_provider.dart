import 'package:flutter/material.dart';
import 'package:temporal_zodiac/features/favorites/domain/repositories/recents_repository.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

class RecentsProvider extends ChangeNotifier {
  final RecentsRepository repository;

  RecentsProvider({required this.repository});

  List<Place> _recents = [];
  List<Place> get recents => _recents;

  Future<void> loadRecents() async {
    _recents = await repository.getRecents();
    notifyListeners();
  }

  Future<void> addRecent(Place place) async {
    await repository.addRecent(place);
    await loadRecents();
  }
}
