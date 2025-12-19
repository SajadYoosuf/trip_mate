import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home_rounded,
                color: navigationShell.currentIndex == 0
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: () => navigationShell.goBranch(0),
              tooltip: 'Home',
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: Icon(
                Icons.favorite_rounded,
                color: navigationShell.currentIndex == 2
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: () => navigationShell.goBranch(2),
              tooltip: 'Favorites',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () => navigationShell.goBranch(1), // Chat is index 1
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
