import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/recents_provider.dart';
import 'package:temporal_zodiac/features/home/presentation/widgets/place_card.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Places'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Saved"),
              Tab(text: "Recent"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Favorites Tab
            Consumer<FavoritesProvider>(
              builder: (context, provider, child) {
                if (provider.favorites.isEmpty) {
                  return const Center(child: Text("No favorites yet"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.favorites.length,
                  itemBuilder: (context, index) {
                    final place = provider.favorites[index];
                    return PlaceCard(
                      place: place,
                      isHorizontal: false,
                      onTap: () {
                        context.read<RecentsProvider>().addRecent(place);
                         context.go('/home/details', extra: place);
                      },
                    );
                  },
                );
              },
            ),
            // Recents Tab
            Consumer<RecentsProvider>(
              builder: (context, provider, child) {
                if (provider.recents.isEmpty) {
                   return const Center(child: Text("No recent places"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.recents.length,
                  itemBuilder: (context, index) {
                    final place = provider.recents[index];
                    return PlaceCard(
                      place: place,
                      isHorizontal: false,
                      onTap: () {
                         context.go('/home/details', extra: place);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
