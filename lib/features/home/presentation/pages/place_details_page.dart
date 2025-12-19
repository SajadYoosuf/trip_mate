import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';

class PlaceDetailsPage extends StatelessWidget {
  final Place place;

  const PlaceDetailsPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(place.name),
              background: CachedNetworkImage(
                imageUrl: place.imageUrl,
                fit: BoxFit.cover,
                 placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(place.type)),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber),
                      Text(" ${place.rating}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "About",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                   Consumer<FavoritesProvider>(
                    builder: (context, provider, child) {
                      final isFav = provider.isFavorite(place.id);
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            provider.toggleFavorite(place);
                          },
                          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                          label: Text(isFav ? "Remove from Favorites" : "Add to Favorites"),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFav ? Colors.red : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
