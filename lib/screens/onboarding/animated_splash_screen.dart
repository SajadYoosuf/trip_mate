import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:temporal_zodiac/services/preferences_service.dart';
import 'package:temporal_zodiac/providers/auth_provider.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with TickerProviderStateMixin {
  late final AnimationController _totalController;
  late final Animation<double> _bgZoomAnimation;
  late final Animation<double> _travelerMoveAnimation;
  late final Animation<double> _flagOpacityAnimation;
  late final Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _totalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Zoom in background slightly
    _bgZoomAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _totalController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Move traveler from left to center-ish
    _travelerMoveAnimation = Tween<double>(begin: -100, end: 40).animate(
      CurvedAnimation(
        parent: _totalController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOutQuad),
      ),
    );

    // Flag appears after traveler reaches summit
    _flagOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _totalController,
        curve: const Interval(0.65, 0.8, curve: Curves.easeIn),
      ),
    );

    // Name fades in at the end
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _totalController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _totalController.forward().then((_) => _checkAppState());
  }

  Future<void> _checkAppState() async {
    // Extra delay to let the final state linger
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final prefs = PreferencesService();
    final authProvider = context.read<AuthProvider>();
    
    final isOnboardingCompleted = await prefs.isOnboardingCompleted();
    final isLoggedIn = authProvider.isAuthenticated;

    if (!mounted) return;

    if (!isOnboardingCompleted) {
      context.go('/onboarding');
    } else if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _totalController,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Mountain
              Transform.scale(
                scale: _bgZoomAnimation.value,
                child: Image.asset(
                  'assets/images/splash/mountain_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              
              // Traveler
              Positioned(
                bottom: 120, // Adjust based on background height
                left: MediaQuery.of(context).size.width / 2 + _travelerMoveAnimation.value - 100,
                child: Opacity(
                  opacity: _totalController.value > 0.1 ? 1.0 : 0.0,
                  child: Image.asset(
                    'assets/images/splash/traveler.png',
                    height: 120,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),

              // Flag at summit
              Positioned(
                bottom: 240, // Summit point area
                left: MediaQuery.of(context).size.width / 2 - 20,
                child: Opacity(
                  opacity: _flagOpacityAnimation.value,
                  child: Image.asset(
                    'assets/images/splash/flag.png',
                    height: 60,
                  ),
                ),
              ),

              // Overlay Gradient for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3 * _textOpacityAnimation.value),
                      ],
                    ),
                  ),
                ),
              ),

              // App Name
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        "Trip Mate",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black45,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your Indian Journey Starts Here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
