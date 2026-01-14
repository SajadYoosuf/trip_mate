import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/core/app_router.dart';
import 'package:temporal_zodiac/services/preferences_service.dart';
import 'package:temporal_zodiac/core/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:temporal_zodiac/services/auth/firebase_auth_repository_impl.dart';
import 'package:temporal_zodiac/services/leaderboard/leaderboard_service.dart';
import 'package:temporal_zodiac/providers/leaderboard_provider.dart';
import 'package:temporal_zodiac/providers/auth_provider.dart';
import 'package:temporal_zodiac/services/home/google_places_repository_impl.dart';
import 'package:temporal_zodiac/services/home/places_repository.dart';
import 'package:temporal_zodiac/providers/home_provider.dart';
import 'package:temporal_zodiac/services/chat/gemini_chat_repository_impl.dart';
import 'package:temporal_zodiac/services/chat/chat_repository.dart';
import 'package:temporal_zodiac/providers/chat_provider.dart';
import 'package:temporal_zodiac/models/place_hive_model.dart';
import 'package:temporal_zodiac/services/favorites/favorites_repository_impl.dart';
import 'package:temporal_zodiac/services/favorites/favorites_repository.dart';
import 'package:temporal_zodiac/providers/favorites_provider.dart';
import 'package:temporal_zodiac/services/favorites/recents_repository_impl.dart';
import 'package:temporal_zodiac/services/favorites/recents_repository.dart';
import 'package:temporal_zodiac/providers/recents_provider.dart';
import 'package:temporal_zodiac/services/favorites/visited_repository_impl.dart';
import 'package:temporal_zodiac/services/favorites/visited_repository.dart';
import 'package:temporal_zodiac/providers/visited_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:temporal_zodiac/services/trip/firestore_trip_repository_impl.dart';
import 'package:temporal_zodiac/services/trip/trip_repository.dart';
import 'package:temporal_zodiac/providers/trip_provider.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PlaceHiveModelAdapter());
  final favoritesBox = await Hive.openBox<PlaceHiveModel>('favorites');
  final recentsBox = await Hive.openBox<PlaceHiveModel>('recents');
  final visitedBox = await Hive.openBox<PlaceHiveModel>('visited');

  // Initialize Services & Repositories
  final preferencesService = PreferencesService();
  final authRepository = FirebaseAuthRepositoryImpl();
  final authProvider = AuthProvider(
    repository: authRepository,
    preferencesService: preferencesService,
  );
  
  // Check initial auth state
  await authProvider.checkAuthStatus();

  runApp(TravelMateApp(
    favoritesBox: favoritesBox,
    recentsBox: recentsBox,
    visitedBox: visitedBox,
    authProvider: authProvider,
    preferencesService: preferencesService,
  ));
}

class TravelMateApp extends StatelessWidget {
  final Box<PlaceHiveModel> favoritesBox;
  final Box<PlaceHiveModel> recentsBox;
  final Box<PlaceHiveModel> visitedBox;
  final AuthProvider authProvider;
  final PreferencesService preferencesService;

  const TravelMateApp({
    super.key,
    required this.favoritesBox,
    required this.recentsBox,
    required this.visitedBox,
    required this.authProvider,
    required this.preferencesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        Provider<PlacesRepository>(create: (_) => GooglePlacesRepositoryImpl()),
        Provider<LeaderboardService>(create: (_) => LeaderboardService()),
        Provider<ChatRepository>(create: (_) => GeminiChatRepositoryImpl()),
        Provider<FavoritesRepository>(
            create: (_) => FavoritesRepositoryImpl(favoritesBox)),
        Provider<RecentsRepository>(
            create: (_) => RecentsRepositoryImpl(recentsBox)),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            googlePlacesRepository: context.read<PlacesRepository>(),
          )..loadPlaces(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            repository: context.read<ChatRepository>(),
            preferencesService: preferencesService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(
            repository: context.read<FavoritesRepository>(),
          )..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (context) => LeaderboardProvider(
            context.read<LeaderboardService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RecentsProvider(
            repository: context.read<RecentsRepository>(),
          )..loadRecents(),
        ),
        Provider<VisitedRepository>(
            create: (_) => VisitedRepositoryImpl(visitedBox)),
        ChangeNotifierProvider(
          create: (context) => VisitedProvider(
            context.read<VisitedRepository>(),
          )..loadVisitedPlaces(),
        ),
        Provider<TripRepository>(create: (_) => FirestoreTripRepositoryImpl()),
        ChangeNotifierProxyProvider<AuthProvider, TripProvider>(
          create: (context) => TripProvider(
             context.read<TripRepository>(),
             context.read<AuthProvider>().currentUser?.id ?? '',
          ),
          update: (context, auth, previous) => TripProvider(
            context.read<TripRepository>(),
            auth.currentUser?.id ?? '',
          ),
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
