import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:temporal_zodiac/core/presentation/widgets/bottom_nav_scaffold.dart';
import 'package:temporal_zodiac/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:temporal_zodiac/features/auth/presentation/pages/login_page.dart';
import 'package:temporal_zodiac/features/auth/presentation/pages/signup_page.dart';
import 'package:temporal_zodiac/features/auth/presentation/providers/auth_provider.dart';
import 'package:temporal_zodiac/features/chat/presentation/pages/chat_page.dart';
import 'package:temporal_zodiac/features/favorites/presentation/pages/favorites_page.dart';
import 'package:temporal_zodiac/features/home/presentation/pages/home_page.dart';
import 'package:temporal_zodiac/features/home/presentation/pages/place_details_page.dart';
import 'package:temporal_zodiac/features/home/domain/entities/place.dart';
import 'package:temporal_zodiac/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:temporal_zodiac/core/services/preferences_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter(AuthProvider authProvider, PreferencesService prefs) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) async {
      final isOnboardingCompleted = await prefs.isOnboardingCompleted();
      final isLoggedIn = authProvider.isAuthenticated;
      
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToForgotPassword = state.matchedLocation == '/forgot_password';
      
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
                path: '/chat',
                builder: (context, state) => const ChatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
