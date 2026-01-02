import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip_member_location.dart';
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
    if (_currentUserId.isNotEmpty) {
      _subscribeToTrips();
      _subscribeToRequests();
    }
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
    }, onError: (e) {
      debugPrint("Trip Stream Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  void _subscribeToRequests() async {
     (await _repository.getIncomingRequestsStream(_currentUserId)).listen((updatedRequests) {
      _incomingRequests = updatedRequests;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Request Stream Error: $e");
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

  Future<void> addPlaceToTrip(String tripId, String placeId) async {
    await _repository.addPlaceToTrip(tripId, placeId);
  }

  // --- Live Location ---
  List<TripMemberLocation> _memberLocations = [];
  bool _isLiveLocationEnabled = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<List<TripMemberLocation>>? _membersLocationSubscription;

  List<TripMemberLocation> get memberLocations => _memberLocations;
  bool get isLiveLocationEnabled => _isLiveLocationEnabled;

  Future<void> startLiveLocation(String tripId) async {
    if (_isLiveLocationEnabled) return;

    // 1. Permission check
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _isLiveLocationEnabled = true;
    notifyListeners();

    // 2. Listen to my location and upload
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        _repository.updateMemberLocation(tripId, _currentUserId, position.latitude, position.longitude);
      }
    });

    // 3. Listen to other members locations
    _membersLocationSubscription = _repository.getTripLocationsStream(tripId).listen((locations) {
      _memberLocations = locations;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Location Stream Error: $e");
    });
  }

  void stopLiveLocation() {
    _isLiveLocationEnabled = false;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    _membersLocationSubscription?.cancel();
    _membersLocationSubscription = null;
    notifyListeners();
  }
}
