import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/home/presentation/providers/home_provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/recents_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:temporal_zodiac/features/home/presentation/widgets/place_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: Consumer<HomeProvider>(
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Nearby Tourist Spots",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.nearbyPlaces.length,
                      itemBuilder: (context, index) {
                        return PlaceCard(
                          place: provider.nearbyPlaces[index],
                          isHorizontal: true,
                          onTap: () {
                            context.read<RecentsProvider>().addRecent(provider.nearbyPlaces[index]);
                            context.go('/home/details', extra: provider.nearbyPlaces[index]);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Popular Activities",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.popularPlaces.length,
                    itemBuilder: (context, index) {
                      return PlaceCard(
                        place: provider.popularPlaces[index],
                        isHorizontal: false,
                        onTap: () {
                          context.read<RecentsProvider>().addRecent(provider.popularPlaces[index]);
                          context.go('/home/details', extra: provider.popularPlaces[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
