import 'package:equatable/equatable.dart';

enum TripRequestStatus { pending, accepted, rejected }

class TripRequest extends Equatable {
  final String id;
  final String tripId;
  final String tripName;
  final String senderId;
  final String senderName;
  final String receiverId;
  final TripRequestStatus status;
  final DateTime timestamp;

  const TripRequest({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, tripId, senderId, receiverId, status, timestamp];
}
