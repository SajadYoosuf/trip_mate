import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/core/router/app_router.dart';
import 'package:temporal_zodiac/core/services/preferences_service.dart';
import 'package:temporal_zodiac/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:temporal_zodiac/features/auth/data/repositories/mock_auth_repository_impl.dart';
import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';
import 'package:temporal_zodiac/features/home/data/repositories/mock_place_repository_impl.dart';
import 'package:temporal_zodiac/features/home/domain/repositories/place_repository.dart';
import 'package:temporal_zodiac/features/home/presentation/providers/home_provider.dart';
import 'package:temporal_zodiac/features/chat/data/repositories/mock_chat_repository_impl.dart';
import 'package:temporal_zodiac/features/chat/domain/repositories/chat_repository.dart';
import 'package:temporal_zodiac/features/chat/presentation/providers/chat_provider.dart';
import 'package:temporal_zodiac/features/favorites/data/models/place_hive_model.dart';
import 'package:temporal_zodiac/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:temporal_zodiac/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:temporal_zodiac/features/favorites/data/repositories/recents_repository_impl.dart';
import 'package:temporal_zodiac/features/favorites/domain/repositories/recents_repository.dart';
import 'package:temporal_zodiac/features/favorites/presentation/providers/recents_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PlaceHiveModelAdapter());
  final favoritesBox = await Hive.openBox<PlaceHiveModel>('favorites');
  final recentsBox = await Hive.openBox<PlaceHiveModel>('recents');

  // Initialize Services & Repositories
  final preferencesService = PreferencesService();
  final authRepository = MockAuthRepositoryImpl();
  final authProvider = AuthProvider(
    repository: authRepository,
    preferencesService: preferencesService,
  );
  
  // Check initial auth state
  await authProvider.checkAuthStatus();

  runApp(TravelMateApp(
    favoritesBox: favoritesBox,
    recentsBox: recentsBox,
    authProvider: authProvider,
    preferencesService: preferencesService,
  ));
}

class TravelMateApp extends StatelessWidget {
  final Box<PlaceHiveModel> favoritesBox;
  final Box<PlaceHiveModel> recentsBox;
  final AuthProvider authProvider;
  final PreferencesService preferencesService;

  const TravelMateApp({
    super.key,
    required this.favoritesBox,
    required this.recentsBox,
    required this.authProvider,
    required this.preferencesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider<PlaceRepository>(create: (_) => MockPlaceRepositoryImpl()),
        Provider<ChatRepository>(create: (_) => MockChatRepositoryImpl()),
        Provider<FavoritesRepository>(
            create: (_) => FavoritesRepositoryImpl(favoritesBox)),
        Provider<RecentsRepository>(
            create: (_) => RecentsRepositoryImpl(recentsBox)),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            repository: context.read<PlaceRepository>(),
          )..loadPlaces(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            repository: context.read<ChatRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(
            repository: context.read<FavoritesRepository>(),
          )..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (context) => RecentsProvider(
            repository: context.read<RecentsRepository>(),
          )..loadRecents(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Travel Mate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme, // Keeping it but it won't be used
        themeMode: ThemeMode.light,
        routerConfig: createRouter(authProvider, preferencesService),
      ),
    );
  }
}
