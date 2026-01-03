import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip.dart';
import 'package:temporal_zodiac/features/trip/presentation/providers/trip_provider.dart';

import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';

class TripMapPage extends StatefulWidget {
  final Trip trip;
  const TripMapPage({super.key, required this.trip});

  @override
  State<TripMapPage> createState() => _TripMapPageState();
}

class _TripMapPageState extends State<TripMapPage> {
  final MapController _mapController = MapController();
  
  final LatLng _defaultCenter = const LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Map: ${widget.trip.name}")),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final markers = <Marker>[];

              for (final loc in provider.memberLocations) {
                 markers.add(
                   Marker(
                     point: LatLng(loc.latitude, loc.longitude),
                     width: 100, // Increased width for name
                     height: 90, // Increased height for name stack
                     child: GestureDetector(
                       onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(loc.userName ?? "Member Location"),
                              content: Text("Last updated: ${loc.timestamp.hour}:${loc.timestamp.minute.toString().padLeft(2, '0')}"),
                              actions: [
                                TextButton.icon(
                                  icon: const Icon(Icons.directions),
                                  label: const Text("Directions"),
                                  onPressed: () async {
                                    final Uri googleMapsUrl = Uri.parse(
                                      'https://www.google.com/maps/dir/?api=1&destination=${loc.latitude},${loc.longitude}');
                                    try {
                                        if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
                                            throw 'Could not launch $googleMapsUrl';
                                        }
                                    } catch (e) {
                                        debugPrint("Error launching map: $e");
                                        if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
                                        }
                                    }
                                  },
                                ),
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            )
                          );
                       },
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           if (loc.userName != null)
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.8),
                                 borderRadius: BorderRadius.circular(4),
                                 border: Border.all(color: Colors.grey.shade300)
                               ),
                               child: Text(
                                 loc.userName!, 
                                 style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 1,
                                 textAlign: TextAlign.center,
                               ),
                             ),
                           const SizedBox(height: 2),
                           Container(
                             padding: const EdgeInsets.all(2),
                             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                             child: CircleAvatar(
                               radius: 12,
                               backgroundImage: loc.userPhotoUrl != null ? NetworkImage(loc.userPhotoUrl!) : null,
                               child: loc.userPhotoUrl == null 
                                  ? Text(
                                      loc.userName?.isNotEmpty == true ? loc.userName![0].toUpperCase() : "?",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                                    ) 
                                  : null,
                             ),
                           ),
                           const Icon(Icons.location_on, color: Colors.blue, size: 30),
                         ],
                       ),
                     ),
                   )
                 );
              }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter, 
                  initialZoom: 5,
                ),
                children: [
                   TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.temporal_zodiac',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              if (!provider.isLiveLocationEnabled && markers.isEmpty)
                  Positioned(
                      top: 10, left: 10, right: 10,
                      child: Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Enable Live Location in Trip Details to see members and be seen.", textAlign: TextAlign.center),
                          )
                      )
                  )
            ],
          );
        },
      ),
    );
  }
}
