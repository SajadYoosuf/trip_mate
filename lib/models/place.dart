import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String id;
  final String name;
  final String description; // Short description
  final String imageUrl;
  final double distance; // In km
  final double rating;
  final String type;
  final double? latitude;
  final double? longitude;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.rating,
    required this.type,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, distance, rating, type, latitude, longitude];
}
