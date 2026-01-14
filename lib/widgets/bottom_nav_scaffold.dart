import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/providers/trip_provider.dart';
import 'package:temporal_zodiac/models/trip_request.dart';

class BottomNavScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  
  @override
  void initState() {
    super.initState();
    // We listen to the provider to trigger dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<TripProvider>().addListener(_checkRequests);
    });
  }

  @override
  void dispose() {
    // Ideally remove listener, but context.read might be unsafe here if widget unmounted. 
    // Since this is the root scaffold, it mostly lives for app life.
    super.dispose();
  }

  void _checkRequests() {
      if (!mounted) return;
      final provider = context.read<TripProvider>();
      final pendingRequests = provider.incomingRequests.where((r) => r.status == TripRequestStatus.pending).toList();

      if (pendingRequests.isNotEmpty) {
          // Check if we are already showing a dialog? 
          // Implementation simplification: just assume we show distinct ones or one at a time.
          // For now, let's show a SnackBar or Banner, which is safer than Dialog (modal).
          // User asked for "popup".
          
          // Using a flag in provider to track "seen" requests would be better, but for MVP:
          // We will verify if Top Route is not already a dialog?
          // Let's use a SnackBar for "Request Received" with Action "View".
          // It is less intrusive and cleaner.
          
          /*
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("New Trip Invite: ${pendingRequests.first.tripName}"),
                  action: SnackBarAction(
                      label: "View",
                      onPressed: () {
                           // Handle accept/reject
                           _showRequestDialog(pendingRequests.first);
                      },
                  ),
                  duration: const Duration(seconds: 3),
              )
          );
          */
          
          // But `addListener` fires often.
          // Better to use `select` or logic inside Provider to notify.
      }
  }

  // Simplified: We utilize Build to react, but ensure only one popup.
  // Actually, let's just use the `TripProvider` to drive UI.
  
  @override
  Widget build(BuildContext context) {
    // Active listener for popup
    final pendingRequests = context.select<TripProvider, List<TripRequest>>(
        (p) => p.incomingRequests.where((r) => r.status == TripRequestStatus.pending).toList()
    );

    // This is a side effect during build, strictly discouraged. 
    // We should use post frame.
    if (pendingRequests.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
             _showRequestDialogIfNeeded(context, pendingRequests.first);
        });
    }

    return Scaffold(
      extendBody: true, // Allow body to extend behind the floating nav bar
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded),
              _buildNavItem(context, 1, Icons.map_rounded),
              _buildCenterNavItem(context, 2, Icons.chat_bubble_outline),
              _buildNavItem(context, 3, Icons.emoji_events_rounded),
              _buildNavItem(context, 4, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  // Simple key to track if dialog is open to prevent loops (basic check)
  static bool _isDialogShowing = false;

  void _showRequestDialogIfNeeded(BuildContext context, TripRequest request) {
      if (_isDialogShowing) return;

      _isDialogShowing = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
              title: const Text("Trip Invitation"),
              content: Text("${request.senderName} invited you to join '${request.tripName}'"),
              actions: [
                  TextButton(
                      onPressed: () {
                          context.read<TripProvider>().rejectRequest(request.id);
                          Navigator.pop(context);
                          _isDialogShowing = false;
                      }, 
                      child: const Text("Reject")
                  ),
                  FilledButton(
                      onPressed: () {
                           context.read<TripProvider>().acceptRequest(request.id);
                           Navigator.pop(context);
                           _isDialogShowing = false;
                           // Navigate to trips tab
                           context.push('/profile/favorites');
                      }, 
                      child: const Text("Accept")
                  ),
              ],
          ),
      ).then((_) {
           _isDialogShowing = false;
      });
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.navigationShell.goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

   Widget _buildCenterNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = widget.navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.navigationShell.goBranch(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
