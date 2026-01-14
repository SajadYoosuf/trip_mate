
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/providers/home_provider.dart';

class GlobalMapPage extends StatefulWidget {
  const GlobalMapPage({super.key});

  @override
  State<GlobalMapPage> createState() => _GlobalMapPageState();
}

class _GlobalMapPageState extends State<GlobalMapPage> {
  // Default to somewhere scenic or user's last known if available, but for now London
  final LatLng _initialCenter = const LatLng(51.5, -0.09); 
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentLocation!, 13.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access places from HomeProvider
    final homeProvider = context.watch<HomeProvider>();
    
    final markers = <Marker>[];
    
    // Add User Location Marker (Pulse Effect)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 30,
              ),
            ],
          ),
        ),
      );
    }

    // Add Places Markers (Custom Image Markers)
    final allPlaces = [...homeProvider.nearbyPlaces, ...homeProvider.popularPlaces];
    for (final place in allPlaces) {
      if (place.latitude != null && place.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(place.latitude!, place.longitude!),
            width: 60, // Sized for visibility
            height: 60,
            child: GestureDetector(
                onTap: () {
                    // Small Popup on Tap
                    showDialog(
                        context: context, 
                        builder: (context) => AlertDialog(
                             backgroundColor: Theme.of(context).cardTheme.color,
                            title: Text(place.name, style: Theme.of(context).textTheme.titleMedium),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    if(place.imageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: place.imageUrl, 
                                            height: 120, 
                                            width: double.infinity, 
                                            fit: BoxFit.cover
                                          ),
                                        ),
                                    const SizedBox(height: 8),
                                    Text(place.description, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${place.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ]),
                                ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  final Uri googleMapsUrl = Uri.parse(
                                      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}');
                                  try {
                                    if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
                                      throw 'Could not launch $googleMapsUrl';
                                    }
                                  } catch (e) {
                                    debugPrint("Error launching map: $e");
                                  }
                                },
                                child: const Text('Directions'),
                              ),
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                            ],
                        )
                    );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Slightly less than container
                    child: CachedNetworkImage(
                      imageUrl: place.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[300]),
                      errorWidget: (context, url, err) => const Icon(Icons.location_on, color: Colors.red),
                    ),
                  ),
                ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Travel Map'), // Transparent by theme
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 9.2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.temporal_zodiac',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          // Clean FAB for Location
          Positioned(
            bottom: 100, // Above potentially custom bottom nav
             right: 20,
            child: FloatingActionButton(
              heroTag: "global_map_fab",
              onPressed: _determinePosition,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
