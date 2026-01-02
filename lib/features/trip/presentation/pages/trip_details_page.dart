import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/places_repository.dart';
import 'package:temporal_zodiac/features/home/presentation/pages/place_details_page.dart';
import 'package:temporal_zodiac/features/trip/domain/entities/trip.dart';
import 'package:temporal_zodiac/features/trip/presentation/providers/trip_provider.dart';
import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class TripDetailsPage extends StatelessWidget {
  final Trip trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: [
            IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                    context.push('/favorites/trip/map', extra: trip);
                },
            ),
            IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {
                    context.push('/favorites/trip/chat', extra: trip);
                },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Members Section
            _buildMembersSection(context),
            const Divider(),
            
            // Places / Itinerary
             _buildPlacesSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
               _showInviteFriendDialog(context);
          },
          icon: const Icon(Icons.person_add),
          label: const Text("Invite Friend"),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text("Trip Members (${trip.memberIds.length})", style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SizedBox(
                      height: 60,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: trip.memberIds.length,
                          itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                      child: Text(trip.memberIds[index].substring(0, 1).toUpperCase()), // Placeholder for initial
                                      // backgroundImage: NetworkImage(...) if we fetch user details
                                  ),
                              );
                          },
                      ),
                  ),
              ],
          ),
      );
  }
  
  Widget _buildPlacesSection(BuildContext context) {
       return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text("Itinerary", style: Theme.of(context).textTheme.titleSmall),
                  if (trip.placeIds.isEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                              child: Text("No places added yet.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                          ),
                      )
                  else
                      // Fetch places logic needed, skipping for now
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trip.placeIds.length,
                          itemBuilder: (context, index) {
                              final placeId = trip.placeIds[index];
                              return FutureBuilder<Place?>(
                                future: context.read<PlacesRepository>().getPlaceDetails(placeId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                     return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                                     );
                                  }
                                  
                                  if (snapshot.hasError || !snapshot.hasData) {
                                     return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: const Icon(Icons.error_outline),
                                        title: Text("Place unavailable ($placeId)"),
                                        subtitle: const Text("Could not load details"),
                                      ),
                                     );
                                  }

                                  final place = snapshot.data!;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                         Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: place)));
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CachedNetworkImage(
                                              imageUrl: place.imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                                              errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 4),
                                                  Text(place.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.primary),
                                                      const SizedBox(width: 4),
                                                      Text(place.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                          }
                      ),
              ],
          ),
      );
  }

  void _showInviteFriendDialog(BuildContext context) {
      final searchController = TextEditingController();
      
      showModalBottomSheet(
          context: context, 
          isScrollControlled: true,
          useRootNavigator: true, 
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
              return DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                      return Consumer<TripProvider>(
                          builder: (context, provider, child) {
                              return Padding(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                          Text("Invite Friends", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                                          const SizedBox(height: 16),
                                          TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                  hintText: "Search by name...",
                                                  prefixIcon: const Icon(Icons.search),
                                                  suffixIcon: IconButton(
                                                      icon: const Icon(Icons.arrow_forward),
                                                      onPressed: () => provider.searchUsers(searchController.text),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                              ),
                                              onSubmitted: (val) => provider.searchUsers(val),
                                              textInputAction: TextInputAction.search,
                                          ),
                                          const SizedBox(height: 16),
                                          if (provider.isSearchingUsers)
                                              const CircularProgressIndicator()
                                          else 
                                              Expanded(
                                                  child: ListView.builder(
                                                      controller: scrollController,
                                                      itemCount: provider.searchResults.length,
                                                      itemBuilder: (context, index) {
                                                          final user = provider.searchResults[index];
                                                          // Don't show if already in trip
                                                          if (trip.memberIds.contains(user.id)) return const SizedBox.shrink();

                                                          return ListTile(
                                                              leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl ?? 'https://via.placeholder.com/150')),
                                                              title: Text(user.name),
                                                              subtitle: Text(user.email),
                                                              trailing: IconButton(
                                                                  icon: const Icon(Icons.person_add, color: Colors.blue),
                                                                  onPressed: () async {
                                                                      await provider.sendInvite(trip.id, user.id);
                                                                      Navigator.pop(context); // Close sheet
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(content: Text("Invite sent to ${user.name}!"))
                                                                      );
                                                                  },
                                                              ),
                                                          );
                                                      },
                                                  ),
                                              ),
                                      ],
                                  ),
                              );
                          },
                      );
                  }
              );
          }
      );
  }
}
