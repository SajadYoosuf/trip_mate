class TripMemberLocation {
  final String userId;
  final String? userName;
  final String? userPhotoUrl;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  TripMemberLocation({
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}
