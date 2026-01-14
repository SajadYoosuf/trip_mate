
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/providers/auth_provider.dart';
import 'package:temporal_zodiac/providers/favorites_provider.dart';
import 'package:temporal_zodiac/providers/visited_provider.dart';
import 'package:temporal_zodiac/providers/recents_provider.dart';
import 'package:temporal_zodiac/widgets/home/saved_place_card.dart';
import 'package:temporal_zodiac/screens/trip/trip_list_page.dart';
import 'package:temporal_zodiac/models/place.dart';
import 'package:temporal_zodiac/models/user.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      await context.read<AuthProvider>().updateProfile(
            name: _nameController.text,
            phone: _phoneController.text,
          );
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        final downloadUrl = await context
            .read<AuthProvider>()
            .uploadProfileImage(pickedFile.path);
        
        if (mounted) {
          await context
              .read<AuthProvider>()
              .updateProfile(
                name: _nameController.text,
                phone: _phoneController.text,
                photoUrl: downloadUrl,
              );
              
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile photo updated')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isLoading = context.watch<AuthProvider>().isLoading;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutConfirmation(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user.photoUrl != null
                                ? MemoryImage(base64Decode(user.photoUrl!))
                                : null,
                            child: user.photoUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    size: 16, color: Colors.white),
                                onPressed: isLoading ? null : _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: "Info", icon: Icon(Icons.badge_outlined, size: 20)),
                      Tab(text: "Saved", icon: Icon(Icons.favorite_outline, size: 20)),
                      Tab(text: "Visited", icon: Icon(Icons.location_on_outlined, size: 20)),
                      Tab(text: "Trips", icon: Icon(Icons.luggage_outlined, size: 20)),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(user, isLoading),
            _buildPlaceGrid<FavoritesProvider>(
              context,
              emptyMessage: "No saved places yet.\nStart exploring!",
              emptyIcon: Icons.favorite_border_rounded,
              getPlaces: (p) => p.favorites,
            ),
            _buildPlaceGrid<VisitedProvider>(
              context,
              emptyMessage: "You haven't visited any places yet.",
              emptyIcon: Icons.location_on_outlined,
              getPlaces: (p) => p.visitedPlaces,
            ),
            const TripListPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(User user, bool isLoading) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        children: [
          if (_isEditing) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = user.name;
                        _phoneController.text = user.phone ?? '';
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _updateProfile,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.phone_iphone),
              title: const Text('Phone Number'),
              subtitle: Text(user.phone ?? 'Not set'),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => setState(() => _isEditing = true),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.star_outline, color: Colors.orange),
              title: const Text('Traveler Level'),
              subtitle: const Text('Gold Member'),
              trailing: Chip(
                label: Text('${user.points} XP'),
                backgroundColor: Colors.orange.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Account Detail'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ],
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                context.push('/home/details', extra: place);
              },
            );
          },
        );
      },
    );
  }
}
