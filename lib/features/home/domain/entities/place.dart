import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String id;
  final String name;
  final String description; // Short description
  final String imageUrl;
  final double distance; // In km
  final double rating;
  final String type; // e.g., "Park", "Restaurant"

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.rating,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, distance, rating, type];
}
