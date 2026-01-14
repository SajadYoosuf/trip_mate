import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/providers/favorites_provider.dart';
import 'package:temporal_zodiac/providers/recents_provider.dart';
import 'package:temporal_zodiac/providers/visited_provider.dart';
import 'package:temporal_zodiac/widgets/home/saved_place_card.dart';
import 'package:temporal_zodiac/screens/trip/trip_list_page.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Journey'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Saved"),
              Tab(text: "Visited"),
              Tab(text: "Trips"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Favorites Tab
            _buildPlaceGrid<FavoritesProvider>(
              context,
              emptyMessage: "No saved places yet.\nStart exploring!",
              emptyIcon: Icons.favorite_border_rounded,
              getPlaces: (p) => p.favorites,
            ),
            // Visited Tab
            _buildPlaceGrid<VisitedProvider>(
              context,
              emptyMessage: "You haven't visited any places yet.",
              emptyIcon: Icons.location_on_outlined,
              getPlaces: (p) => p.visitedPlaces,
            ),
            // Trip Plans Tab
            const TripListPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceGrid<T extends ChangeNotifier>(
    BuildContext context, {
    required String emptyMessage,
    required IconData emptyIcon,
    required List<dynamic> Function(T) getPlaces,
  }) {
    return Consumer<T>(
      builder: (context, provider, child) {
        final places = getPlaces(provider);
        if (places.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return MasonryGridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return SavedPlaceCard(
              place: place,
              onTap: () {
                context.read<RecentsProvider>().addRecent(place);
                context.go('/home/details', extra: place);
              },
            );
          },
        );
      },
    );
  }
}
