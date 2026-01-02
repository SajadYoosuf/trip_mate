import 'package:flutter/material.dart';
import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip_request.dart';
import 'package:temporal_zodiac/features/trip/domain/repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;
  final String _currentUserId;

  List<Trip> _trips = [];
  List<TripRequest> _incomingRequests = [];
  bool _isLoading = false;
  
  // Trip Creation
  String _creationError = '';
  
  // User Search
  List<User> _searchResults = [];
  bool _isSearchingUsers = false;

  TripProvider(this._repository, this._currentUserId) {
    _subscribeToTrips();
    _subscribeToRequests();
  }

  List<Trip> get trips => _trips;
  List<TripRequest> get incomingRequests => _incomingRequests;
  bool get isLoading => _isLoading;
  String get creationError => _creationError;
  List<User> get searchResults => _searchResults;
  bool get isSearchingUsers => _isSearchingUsers;

  void _subscribeToTrips() async {
    _isLoading = true;
    notifyListeners();
    
    (await _repository.getUserTripsStream(_currentUserId)).listen((updatedTrips) {
      _trips = updatedTrips;
      _isLoading = false;
      notifyListeners();
    });
  }

  void _subscribeToRequests() async {
     (await _repository.getIncomingRequestsStream(_currentUserId)).listen((updatedRequests) {
      _incomingRequests = updatedRequests;
      
      // Notify user via a callback or expose a flag if a new PENDING request arrives
      // For now, the UI will just react to the list change.
      notifyListeners();
    });   
  }

  Future<bool> createTrip(String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.createTrip(name, _currentUserId);
      return true;
    } catch (e) {
      _creationError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId) async {
    await _repository.acceptTripRequest(requestId);
  }

  Future<void> rejectRequest(String requestId) async {
    await _repository.rejectTripRequest(requestId);
  }

  // --- Search Users ---
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearchingUsers = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchUsers(query);
    } catch (e) {
      debugPrint("User search error: $e");
      _searchResults = [];
    } finally {
      _isSearchingUsers = false;
      notifyListeners();
    }
  }
  
  Future<void> sendInvite(String tripId, String receiverId) async {
    await _repository.sendTripRequest(tripId, _currentUserId, receiverId);
  }
}
