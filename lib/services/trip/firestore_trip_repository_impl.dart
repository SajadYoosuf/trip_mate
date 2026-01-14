import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temporal_zodiac/models/user.dart';
import 'package:temporal_zodiac/models/trip_model.dart';
import 'package:temporal_zodiac/models/trip_request_model.dart';
import 'package:temporal_zodiac/models/trip.dart';
import 'package:temporal_zodiac/models/trip_request.dart';
import 'package:temporal_zodiac/services/trip/trip_repository.dart';
import 'package:temporal_zodiac/models/trip_chat_message.dart';
import 'package:temporal_zodiac/models/trip_member_location.dart';

class FirestoreTripRepositoryImpl implements TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createTrip(String name, String userId) async {
    final docRef = await _firestore.collection('trips').add({
      'name': name,
      'creatorId': userId,
      'memberIds': [userId],
      'placeIds': [],
      'startDate': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<List<Trip>> getUserTrips(String userId) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('memberIds', arrayContains: userId)
        .orderBy('startDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => TripModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<Stream<List<Trip>>> getUserTripsStream(String userId) async {
    return _firestore
        .collection('trips')
        .where('memberIds', arrayContains: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TripModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<void> addPlaceToTrip(String tripId, String placeId) async {
    await _firestore.collection('trips').doc(tripId).update({
      'placeIds': FieldValue.arrayUnion([placeId])
    });
  }

  // --- Requests ---

  @override
  Future<void> sendTripRequest(
      String tripId, String senderId, String receiverId) async {
    // 1. Get Trip details for notification context
    final tripDoc = await _firestore.collection('trips').doc(tripId).get();
    final tripName = tripDoc.data()?['name'] ?? 'Trip';

    // 2. Get Sender details
    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    final senderName = senderDoc.data()?['name'] ?? 'Friend';

    await _firestore.collection('trip_requests').add({
      'tripId': tripId,
      'tripName': tripName,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptTripRequest(String requestId) async {
    final requestDoc =
        await _firestore.collection('trip_requests').doc(requestId).get();
    
    if (!requestDoc.exists) return;

    final data = requestDoc.data()!;
    final tripId = data['tripId'];
    final userId = data['receiverId'];

    // Atomically: 1. Update request status 2. Add user to trip members
    final batch = _firestore.batch();
    
    batch.update(requestDoc.reference, {'status': 'accepted'});
    
    final tripRef = _firestore.collection('trips').doc(tripId);
    batch.update(tripRef, {
      'memberIds': FieldValue.arrayUnion([userId])
    });

    await batch.commit();
  }

  @override
  Future<void> rejectTripRequest(String requestId) async {
    await _firestore
        .collection('trip_requests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  @override
  Future<Stream<List<TripRequest>>> getIncomingRequestsStream(
      String userId) async {
    return _firestore
        .collection('trip_requests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripRequestModel.fromSnapshot(doc))
            .toList());
  }

  // --- Users ---

  @override
  Future<List<User>> searchUsers(String query) async {
    // Basic prefix search by name
    final snapshot = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
       final data = doc.data();
       return User(
         id: doc.id,
         name: data['name'] ?? 'Unknown',
         email: data['email'] ?? '',
         photoUrl: data['photoUrl'],
       );
    }).toList();
  }

  // --- Live Location ---

  @override
  Future<void> updateMemberLocation(String tripId, String userId, double lat, double lng, {String? userName, String? userPhotoUrl}) async {
    final data = {
      'userId': userId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (userName != null) data['userName'] = userName;
    if (userPhotoUrl != null) data['userPhotoUrl'] = userPhotoUrl;
    
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('locations')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  @override
  Stream<List<TripMemberLocation>> getTripLocationsStream(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('locations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TripMemberLocation(
            userId: data['userId'],
            userName: data['userName'],
            userPhotoUrl: data['userPhotoUrl'],
            latitude: (data['latitude'] as num).toDouble(),
            longitude: (data['longitude'] as num).toDouble(),
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now());
      }).toList();
    });
  }

  // --- Group Chat ---

  @override
  Future<void> sendTripMessage(String tripId, String message, String senderId, String senderName) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<TripChatMessage>> getTripMessagesStream(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripChatMessage.fromSnapshot(doc))
            .toList());
  }
}
