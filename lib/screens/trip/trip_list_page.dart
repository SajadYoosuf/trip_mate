import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/providers/trip_provider.dart';
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

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: provider.trips.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ElevatedButton.icon(
                onPressed: () => _showCreateTripDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text("Plan a New Adventure"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            }

            final trip = provider.trips[index - 1];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.luggage_rounded, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  trip.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(trip.startDate),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people_alt_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          "${trip.memberIds.length} Trip Mates",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () {
                  context.push('/profile/favorites/trip', extra: trip);
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
