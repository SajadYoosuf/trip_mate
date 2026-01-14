import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temporal_zodiac/models/trip_request.dart';

class TripRequestModel extends TripRequest {
  const TripRequestModel({
    required super.id,
    required super.tripId,
    required super.tripName,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.status,
    required super.timestamp,
  });

  factory TripRequestModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripRequestModel(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      tripName: data['tripName'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      status: TripRequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => TripRequestStatus.pending,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'tripName': tripName,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
