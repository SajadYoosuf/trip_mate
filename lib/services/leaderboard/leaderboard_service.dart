import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:temporal_zodiac/models/user.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore;

  LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addPoints(String userId, int points) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  Future<List<User>> getGlobalLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch global leaderboard: $e');
    }
  }

  // Optimized for simplicity: Local leaderboard based on same city or just nearby users
  // For now, let's just make it a subset or specific query if we had location in users.
  // Since we don't have location on all users yet, we'll just return a random subset for "Nearby" demo
  // or just filter global for now.
  Future<List<User>> getNearbyLeaderboard() async {
     return getGlobalLeaderboard(); // Placeholder
  }
}
