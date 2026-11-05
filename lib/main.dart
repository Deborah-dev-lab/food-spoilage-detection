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
// FRESHTRACK LANDING / WELCOME SCREEN
// ==========================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color paleGreen = Color(0xFFDCE9D6);
  static const Color softGreen = Color(0xFF2A5340);

  void _openOnboarding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: forest,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BRAND HEADER
                      const Row(
                        children: [
                          Icon(Icons.eco_rounded, color: lime, size: 29),
                          SizedBox(width: 8),
                          Text(
                            'freshtrack.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.9,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: compact ? 28 : 45),

                      // HERO ILLUSTRATION
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: compact ? 205 : 270,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // OUTER CIRCLE
                              Container(
                                width: compact ? 185 : 245,
                                height: compact ? 185 : 245,
                                decoration: BoxDecoration(
                                  color: softGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              // INNER CIRCLE
                              Container(
                                width: compact ? 145 : 195,
                                height: compact ? 145 : 195,
                                decoration: BoxDecoration(
                                  color: lime.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              // MAIN ILLUSTRATION
                              Icon(
                                Icons.eco_rounded,
                                color: lime,
                                size: compact ? 105 : 140,
                              ),

                              // DECORATIVE SPARKLE
                              Positioned(
                                top: compact ? 12 : 20,
                                right: 32,
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: lime.withValues(alpha: 0.8),
                                  size: 25,
                                ),
                              ),

                              // SMALL DECORATIVE LEAF
                              Positioned(
                                bottom: compact ? 17 : 25,
                                left: 28,
                                child: const Icon(
                                  Icons.spa_outlined,
                                  color: paleGreen,
                                  size: 27,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 25 : 40),

                      // INTRODUCTION LABEL
                      const Text(
                        'WELCOME TO FRESHTRACK',
                        style: TextStyle(
                          color: lime,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // MAIN HEADING
                      Text(
                        'Fresh choices\nstart here.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 34 : 39,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          letterSpacing: -1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DESCRIPTION
                      const Text(
                        'A simpler way to understand the visible '
                        'freshness of your fruits and vegetables.',
                        style: TextStyle(
                          color: paleGreen,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: compact ? 25 : 38),

                      // GET STARTED BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => _openOnboarding(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lime,
                            foregroundColor: forest,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, size: 21),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 23),

                      // FOOTER
                      const Center(
                        child: Text(
                          'Discover  •  Check  •  Understand',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: paleGreen,
                            fontSize: 12,
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
