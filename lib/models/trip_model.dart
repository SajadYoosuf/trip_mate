import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temporal_zodiac/models/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.name,
    required super.creatorId,
    required super.memberIds,
    required super.placeIds,
    required super.startDate,
  });

  factory TripModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      name: data['name'] ?? '',
      creatorId: data['creatorId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      placeIds: List<String>.from(data['placeIds'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'placeIds': placeIds,
      'startDate': Timestamp.fromDate(startDate),
    };
  }
}
