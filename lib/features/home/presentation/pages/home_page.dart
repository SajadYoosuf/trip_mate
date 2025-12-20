import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:temporal_zodiac/features/home/presentation/providers/home_provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/recents_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:temporal_zodiac/features/home/presentation/widgets/place_card.dart';
import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine greeting
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    if (hour >= 17) greeting = "Good Evening";

    // Get User Name
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name.split(' ').first ?? 'Traveler';
    final userPhoto = authProvider.currentUser?.photoUrl;

    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            return RefreshIndicator(
              onRefresh: provider.loadPlaces,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hey! $userName",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: userPhoto != null 
                              ? NetworkImage(userPhoto) 
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: userPhoto == null 
                              ? const Icon(Icons.person, color: Colors.grey) 
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Travel is never\na matter of money",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontSize: 32,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const SizedBox(height: 24),

                    // Staggered Grid
                    MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.nearbyPlaces.length,
                      itemBuilder: (context, index) {
                        return PlaceCard(
                          place: provider.nearbyPlaces[index],
                          onTap: () {
                            context.read<RecentsProvider>().addRecent(provider.nearbyPlaces[index]);
                            context.go('/home/details', extra: provider.nearbyPlaces[index]);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80), // Space for FAB or Bottom Nav
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


}
