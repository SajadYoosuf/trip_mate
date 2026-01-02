import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/place_repository.dart';

class MockPlaceRepositoryImpl implements PlaceRepository {
  final List<Place> _nearbyPlaces = [
    const Place(
      id: '1',
      name: 'Silent Valley National Park',
      description: 'A beautiful national park.',
      imageUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969',
      distance: 12.5,
      rating: 4.8,
      type: 'Park',
      latitude: 11.13,
      longitude: 76.42,
    ),
    const Place(
      id: '2',
      name: 'Munnar Tea Gardens',
      description: 'Lush green tea plantations.',
      imageUrl: 'https://images.unsplash.com/photo-1596323067888-97cce305260f',
      distance: 45.0,
      rating: 4.9,
      type: 'Nature',
      latitude: 10.08,
      longitude: 77.06,
    ),
  ];

  final List<Place> _popularPlaces = [
    const Place(
      id: '3',
      name: 'Alleppey Backwaters',
      description: 'Famous backwaters of Kerala.',
      imageUrl: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944',
      distance: 120.0,
      rating: 4.7,
      type: 'Water',
      latitude: 9.49,
      longitude: 76.33,
    ),
  ];

  @override
  Future<List<Place>> getNearbyPlaces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _nearbyPlaces;
  }

  @override
  Future<List<Place>> getPopularPlaces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _popularPlaces;
  }
}
