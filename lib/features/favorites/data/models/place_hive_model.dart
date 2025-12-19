import 'package:hive/hive.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

part 'place_hive_model.g.dart';

@HiveType(typeId: 0)
class PlaceHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String imageUrl;

  @HiveField(4)
  late double distance;

  @HiveField(5)
  late double rating;

  @HiveField(6)
  late String type;

  PlaceHiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.rating,
    required this.type,
  });

  factory PlaceHiveModel.fromEntity(Place place) {
    return PlaceHiveModel(
      id: place.id,
      name: place.name,
      description: place.description,
      imageUrl: place.imageUrl,
      distance: place.distance,
      rating: place.rating,
      type: place.type,
    );
  }

  Place toEntity() {
    return Place(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      distance: distance,
      rating: rating,
      type: type,
    );
  }
}
