import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/models/user.dart';
import 'package:temporal_zodiac/providers/leaderboard_provider.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explorer Rankings'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Global"),
              Tab(text: "Nearby"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderboardList(isGlobal: true),
            _LeaderboardList(isGlobal: false),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final bool isGlobal;
  const _LeaderboardList({required this.isGlobal});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = isGlobal ? provider.globalUsers : provider.nearbyUsers;

        if (users.isEmpty) {
          return const Center(child: Text("No rankings available yet."));
        }

        return RefreshIndicator(
          onRefresh: provider.refreshLeaderboards,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              if (index < 3) return const SizedBox.shrink(); // Top 3 handled separately if we wanted a podium, but for now simple list
              return _buildUserTile(context, users[index], index + 1);
            },
            // We can add a podium header here
            shrinkWrap: true,
          ).parent((list) => Column(
            children: [
              if (users.length >= 3) _Podium(topThree: users.take(3).toList()),
              Expanded(child: list),
            ],
          )),
        );
      },
    );
  }

  Widget _buildUserTile(BuildContext context, User user, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              "#$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? Text(user.name[0]) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "${user.points} XP",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          if (rank <= 3) 
            Icon(
              Icons.workspace_premium_rounded, 
              color: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey : Colors.brown[300]),
            ),
        ],
      ),
    );
  }
}

extension _ListParent on Widget {
  Widget parent(Widget Function(Widget) builder) => builder(this);
}

class _Podium extends StatelessWidget {
  final List<User> topThree;
  const _Podium({required this.topThree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (topThree.length >= 2) _PodiumItem(user: topThree[1], rank: 2, height: 100),
          // 1st Place
          if (topThree.length >= 1) _PodiumItem(user: topThree[0], rank: 1, height: 140, isLarge: true),
          // 3rd Place
          if (topThree.length >= 3) _PodiumItem(user: topThree[2], rank: 3, height: 80),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final User user;
  final int rank;
  final double height;
  final bool isLarge;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.height,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
             CircleAvatar(
              radius: isLarge ? 40 : 32,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: isLarge ? 36 : 28,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? Text(user.name[0], style: TextStyle(fontSize: isLarge ? 24 : 18)) : null,
              ),
            ),
            Positioned(
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey[400] : Colors.brown[300]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "#$rank",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isLarge ? 16 : 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${user.points} XP",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: isLarge ? 14 : 12),
        ),
      ],
    );
  }
}
