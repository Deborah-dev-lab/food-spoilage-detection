import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const FreshTrackApp());
}

// ==========================================
// FRESHTRACK APPLICATION
// ==========================================

class FreshTrackApp extends StatelessWidget {
  const FreshTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// SPLASH / WELCOME SCREEN
// ==========================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void openOnboarding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----------------------------------
                      // BRAND HEADER
                      // ----------------------------------

                      const Row(
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            color: AppTheme.forest,
                            size: 28,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'freshtrack.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: AppTheme.forest,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 46),

                      // ----------------------------------
                      // HERO ILLUSTRATION
                      // ----------------------------------
                      Container(
                        height: 290,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: AppTheme.sage,
                          borderRadius: BorderRadius.circular(36),
                        ),

                        child: Stack(
                          alignment: Alignment.center,

                          children: [
                            // Decorative sparkle
                            Positioned(
                              top: 22,
                              right: 25,

                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: AppTheme.forest.withValues(alpha: 0.35),
                                size: 28,
                              ),
                            ),

                            // Background circle
                            Container(
                              width: 210,
                              height: 210,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),

                            // Main leaf illustration
                            const Icon(
                              Icons.eco_rounded,
                              color: AppTheme.forest,
                              size: 135,
                            ),

                            // Small floating leaf
                            const Positioned(
                              left: 38,
                              bottom: 70,

                              child: Icon(
                                Icons.spa_outlined,
                                color: AppTheme.forest,
                                size: 32,
                              ),
                            ),

                            // Illustration label
                            Positioned(
                              bottom: 22,

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Text(
                                  'YOUR FOOD, BETTER UNDERSTOOD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    color: AppTheme.forest,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 38),

                      // ----------------------------------
                      // MAIN HEADING
                      // ----------------------------------
                      const Text(
                        'Fresh choices\nstart here.',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: AppTheme.forest,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'A simpler way to understand the '
                        'freshness of your fruits and vegetables.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppTheme.muted,
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ----------------------------------
                      // GET STARTED BUTTON
                      // ----------------------------------
                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () {
                            openOnboarding(context);
                          },

                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text('Get Started'),

                              Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ----------------------------------
                      // FOOTER
                      // ----------------------------------
                      const Center(
                        child: Text(
                          'Discover  •  Check  •  Understand',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.muted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
