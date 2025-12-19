import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/place_repository.dart';

class MockPlaceRepositoryImpl implements PlaceRepository {
  @override
  Future<List<Place>> getNearbyPlaces() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate latency
    return [
      const Place(
        id: '1',
        name: 'Central Park',
        description: 'A beautiful green space in the heart of the city.',
        imageUrl: 'https://images.unsplash.com/photo-1496417263034-38ec4f0d6b21?auto=format&fit=crop&q=80&w=800',
        distance: 1.2,
        rating: 4.8,
        type: 'Park',
      ),
      const Place(
        id: '2',
        name: 'The Daily Grind',
        description: 'Artisan coffee and pastries.',
        imageUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&q=80&w=800',
        distance: 0.5,
        rating: 4.5,
        type: 'Cafe',
      ),
       const Place(
        id: '3',
        name: 'City Museum',
        description: 'Explore the history of the region.',
        imageUrl: 'https://images.unsplash.com/photo-1544606405-08d1b204bc93?auto=format&fit=crop&q=80&w=800',
        distance: 2.1,
        rating: 4.6,
        type: 'Museum',
      ),
    ];
  }

  @override
  Future<List<Place>> getPopularPlaces() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return [
      const Place(
        id: '4',
        name: 'Golden Gate Bridge',
        description: 'Iconic suspension bridge.',
        imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&q=80&w=800',
        distance: 5.5,
        rating: 4.9,
        type: 'Landmark',
      ),
       const Place(
        id: '5',
        name: 'Ocean Beach',
        description: 'Wide sandy beach with great waves.',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800',
        distance: 8.0,
        rating: 4.7,
        type: 'Beach',
      ),
    ];
  }
}
