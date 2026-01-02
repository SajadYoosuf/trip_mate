import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/features/trip/presentation/providers/trip_provider.dart';
import 'package:temporal_zodiac/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No trips planned yet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Start planning your next adventure!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to create trip
                     _showCreateTripDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create New Trip"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.trips.length + 1, // +1 for "Create New" card
          itemBuilder: (context, index) {
            if (index == 0) {
                // Header / Create New Button
                return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                        onPressed: () => _showCreateTripDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text("Plan a New Trip"),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                    ),
                );
            }

            final trip = provider.trips[index - 1];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  trip.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(trip.startDate),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                     Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          "${trip.memberIds.length} Members",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   context.go('/favorites/trip', extra: trip);
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showCreateTripDialog(BuildContext context) {
      final controller = TextEditingController();
      showDialog(
          context: context, 
          builder: (context) => AlertDialog(
              title: const Text("Name your Trip"),
              content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: "e.g., Summer Vacation 2024",
                      border: OutlineInputBorder(),
                  ),
                  autofocus: true,
              ),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                          if (controller.text.isNotEmpty) {
                              context.read<TripProvider>().createTrip(controller.text);
                              Navigator.pop(context);
                          }
                      }, 
                      child: const Text("Create")
                  ),
              ],
          ),
      );
  }
}
