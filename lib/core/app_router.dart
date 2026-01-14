import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:temporal_zodiac/widgets/bottom_nav_scaffold.dart';
import 'package:temporal_zodiac/screens/auth/forgot_password_page.dart';
import 'package:temporal_zodiac/screens/auth/login_page.dart';
import 'package:temporal_zodiac/screens/auth/signup_page.dart';
import 'package:temporal_zodiac/screens/auth/profile_page.dart';
import 'package:temporal_zodiac/providers/auth_provider.dart';
import 'package:temporal_zodiac/screens/chat/chat_page.dart';
import 'package:temporal_zodiac/screens/favorites/favorites_page.dart';
import 'package:temporal_zodiac/screens/home/home_page.dart';
import 'package:temporal_zodiac/screens/map/global_map_page.dart';
import 'package:temporal_zodiac/screens/home/place_details_page.dart';
import 'package:temporal_zodiac/models/place.dart';
import 'package:temporal_zodiac/screens/onboarding/splash_screen.dart';
import 'package:temporal_zodiac/screens/onboarding/onboarding_page.dart';
import 'package:temporal_zodiac/screens/onboarding/animated_splash_screen.dart';
import 'package:temporal_zodiac/services/preferences_service.dart';
import 'package:temporal_zodiac/screens/trip/trip_map_page.dart';
import 'package:temporal_zodiac/screens/trip/trip_chat_page.dart';

import 'package:temporal_zodiac/models/trip.dart';
import 'package:temporal_zodiac/screens/trip/trip_details_page.dart';
import 'package:temporal_zodiac/screens/leaderboard/leaderboard_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter(AuthProvider authProvider, PreferencesService prefs) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) async {
      final isOnboardingCompleted = await prefs.isOnboardingCompleted();
      final isLoggedIn = authProvider.isAuthenticated;
      
      final isGoingToRoot = state.matchedLocation == '/';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToForgotPassword = state.matchedLocation == '/forgot_password';
      
      // 0. Always allow root (AnimatedSplashScreen) to run its course first
      if (isGoingToRoot) return null;

      // 1. If onboarding not completed, go to onboarding
      if (!isOnboardingCompleted) {
        if (!isGoingToOnboarding) return '/onboarding';
        return null;
      }
      
      // 2. If onboarding completed but not logged in, go to login
      // (Allow signup and forgot password)
      if (!isLoggedIn) {
        if (isGoingToOnboarding) return '/login'; // Prevent going back to onboarding
        if (isGoingToLogin || isGoingToSignup || isGoingToForgotPassword) return null;
        return '/login';
      }

      // 3. If logged in, redirect away from auth/onboarding pages to home
      if (isGoingToLogin || isGoingToSignup || isGoingToOnboarding || isGoingToForgotPassword) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'details',
                    redirect: (context, state) {
                      if (state.extra is! Place) {
                         return '/home';
                      }
                      return null;
                    },
                    builder: (context, state) {
                      final place = state.extra as Place;
                      return PlaceDetailsPage(place: place);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const GlobalMapPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesPage(),
                    routes: [
                      GoRoute(
                        path: 'trip',
                        redirect: (context, state) {
                          if (state.extra is! Trip) {
                            return '/profile';
                          }
                          return null;
                        },
                        builder: (context, state) {
                          final trip = state.extra as Trip;
                          return TripDetailsPage(trip: trip);
                        },
                        routes: [
                          GoRoute(
                            path: 'map',
                            builder: (context, state) =>
                                TripMapPage(trip: state.extra as Trip),
                          ),
                          GoRoute(
                            path: 'chat',
                            builder: (context, state) =>
                                TripChatPage(trip: state.extra as Trip),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
