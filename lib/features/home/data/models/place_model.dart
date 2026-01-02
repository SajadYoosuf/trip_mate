
import 'package:temporal_zodiac/core/constants/api_constants.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.distance,
    required super.rating,
    required super.type,
    super.latitude,
    super.longitude,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final displayName = json['displayName']['text'] as String? ?? 'Unknown Place';
    final formattedAddress = json['formattedAddress'] as String? ?? '';
    final rating = (json['rating'] as num?)?.toDouble() ?? 4.5;
    
    String imageUrl = 'https://via.placeholder.com/400';
    final photos = json['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final photoName = photos[0]['name'] as String?;
      if (photoName != null) {
        imageUrl = 'https://places.googleapis.com/v1/$photoName/media?maxHeightPx=400&maxWidthPx=400&key=${ApiConstants.googlePlacesApiKey}';
      }
    }

    // Location
    double? lat;
    double? lng;
    final location = json['location'] as Map<String, dynamic>?;
    if (location != null) {
      lat = (location['latitude'] as num?)?.toDouble();
      lng = (location['longitude'] as num?)?.toDouble();
    }

    return PlaceModel(
      id: json['name'] as String? ?? formattedAddress,
      name: displayName,
      description: formattedAddress,
      imageUrl: imageUrl, 
      distance: 0.0, 
      rating: rating,
      type: 'Place', 
      latitude: lat,
      longitude: lng,
    );
  }
}
