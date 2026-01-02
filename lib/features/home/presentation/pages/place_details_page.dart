import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/visited_provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsPage extends StatelessWidget {
  final Place place;

  const PlaceDetailsPage({super.key, required this.place});

  Future<void> _launchMap() async {
    if (place.latitude == null || place.longitude == null) return;

    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}');
    
    try {
      if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind app bar for full screen image effect
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.55, // Top 45% is image
            child: CachedNetworkImage(
              imageUrl: place.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

           // Profile/User Icon (Matches reference top right)
           Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: CachedNetworkImage(
              imageUrl: "https://i.pravatar.cc/150?img=30",
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: const Icon(Icons.person, color: Colors.black),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),


          // Draggable/Scrollable Sheet Content
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      place.type, // Map to location if available, else usage type
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  place.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Features (Mocked conditionally if we had data, currently skipping strictly as per request "not have that")
                      // Text("Features", style: Theme.of(context).textTheme.titleLarge),
                      // ...Feature Icons Row... 

                      // Description
                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        place.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Actions
                       Consumer2<FavoritesProvider, VisitedProvider>(
                        builder: (context, favProvider, visitedProvider, child) {
                          final isFav = favProvider.isFavorite(place.id);
                          final isVisited = visitedProvider.isVisited(place.id);
                          return Row(
                            children: [
                              // Favorite Button
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: isFav ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => favProvider.toggleFavorite(place),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Directions Button
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: _launchMap,
                                    style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                        foregroundColor: Theme.of(context).colorScheme.primary
                                    ),
                                    icon: const Icon(Icons.directions),
                                    label: const Text("Directions"),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),
                              
                              // Visited / Action Button
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 56,
                                  child: FilledButton(
                                    onPressed: () {
                                      visitedProvider.toggleVisited(place);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: isVisited ? Colors.green : Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      isVisited ? "Visited" : "Check In", 
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                       const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
