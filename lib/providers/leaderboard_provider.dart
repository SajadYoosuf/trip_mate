import 'package:flutter/foundation.dart';
import 'package:temporal_zodiac/models/user.dart';
import 'package:temporal_zodiac/services/leaderboard/leaderboard_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _service;
  
  List<User> _globalUsers = [];
  List<User> _nearbyUsers = [];
  bool _isLoading = false;
  String? _error;

  LeaderboardProvider(this._service) {
    refreshLeaderboards();
  }

  List<User> get globalUsers => _globalUsers;
  List<User> get nearbyUsers => _nearbyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refreshLeaderboards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _globalUsers = await _service.getGlobalLeaderboard();
      _nearbyUsers = await _service.getNearbyLeaderboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> awardPoints(String userId, int points) async {
    try {
      await _service.addPoints(userId, points);
      await refreshLeaderboards(); // Update the lists
    } catch (e) {
      debugPrint("Award points error: $e");
    }
  }
}
