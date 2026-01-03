import 'package:temporal_zodiac/features/trip/domain/entities/trip.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip_request.dart';
import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';

import 'package:temporal_zodiac/features/trip/domain/entities/trip_member_location.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip_chat_message.dart';

abstract class TripRepository {
  // Trips
  Future<String> createTrip(String name, String userId);
  Future<List<Trip>> getUserTrips(String userId);
  Future<void> addPlaceToTrip(String tripId, String placeId);
  Future<Stream<List<Trip>>> getUserTripsStream(String userId);

  // Requests
  Future<void> sendTripRequest(String tripId, String senderId, String receiverId);
  Future<void> acceptTripRequest(String requestId);
  Future<void> rejectTripRequest(String requestId);
  Future<Stream<List<TripRequest>>> getIncomingRequestsStream(String userId);
  
  // Users
  Future<List<User>> searchUsers(String query);

  // Live Location
  Future<void> updateMemberLocation(String tripId, String userId, double lat, double lng, {String? userName, String? userPhotoUrl});
  Stream<List<TripMemberLocation>> getTripLocationsStream(String tripId);

  // Group Chat
  Future<void> sendTripMessage(String tripId, String message, String senderId, String senderName);
  Stream<List<TripChatMessage>> getTripMessagesStream(String tripId);
}
