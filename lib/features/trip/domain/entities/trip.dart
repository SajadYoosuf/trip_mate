import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String name;
  final String creatorId; // User ID of the creator
  final List<String> memberIds; // List of user IDs in the trip
  final List<String> placeIds; // List of Place IDs or custom objects to store place details
  final DateTime startDate;

  const Trip({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.memberIds,
    required this.placeIds,
    required this.startDate,
  });

  @override
  List<Object?> get props => [id, name, creatorId, memberIds, placeIds, startDate];
}
