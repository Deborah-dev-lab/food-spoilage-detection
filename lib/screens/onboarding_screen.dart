import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color paleGreen = Color(0xFFDCE9D6);
  static const Color softGreen = Color(0xFF2A5340);

  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.camera_alt_outlined,
      number: '01',
      eyebrow: 'DISCOVER',
      title: 'Check your food\nfreshness.',
      description:
          'Capture a photo of your fruits or vegetables '
          'to explore their visible freshness.',
    ),
    _OnboardingPageData(
      icon: Icons.eco_outlined,
      number: '02',
      eyebrow: 'UNDERSTAND',
      title: 'Know your\nproduce better.',
      description:
          'Identify visible signs of spoilage and '
          'learn more about the quality of your food.',
    ),
    _OnboardingPageData(
      icon: Icons.verified_outlined,
      number: '03',
      eyebrow: 'MAKE INFORMED CHOICES',
      title: 'Make every\ncheck count.',
      description:
          'Get helpful freshness insights to support '
          'better food handling decisions.',
    ),
  ];

  void _openHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _openHomeScreen();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: forest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
          child: Column(
            children: [
              // FRESHTRACK HEADER
              Row(
                children: [
                  const Icon(Icons.eco_rounded, color: lime, size: 28),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'freshtrack.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openHomeScreen,
                    style: TextButton.styleFrom(foregroundColor: paleGreen),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // RESPONSIVE ONBOARDING PAGES
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 520;

                        final illustrationHeight = compact ? 150.0 : 220.0;

                        final circleSize = compact ? 140.0 : 200.0;

                        final innerCircleSize = compact ? 105.0 : 150.0;

                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ILLUSTRATION
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: illustrationHeight,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: softGreen,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.09,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: innerCircleSize,
                                          height: innerCircleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: lime.withValues(alpha: 0.13),
                                          ),
                                          child: Icon(
                                            page.icon,
                                            size: compact ? 58 : 80,
                                            color: lime,
                                          ),
                                        ),

                                        Positioned(
                                          top: compact ? 4 : 12,
                                          right: 25,
                                          child: _DecorativeDot(
                                            size: 12,
                                            color: lime.withValues(alpha: 0.8),
                                          ),
                                        ),

                                        Positioned(
                                          bottom: compact ? 8 : 22,
                                          left: 20,
                                          child: _DecorativeDot(
                                            size: 9,
                                            color: paleGreen.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          bottom: compact ? 8 : 22,
                                          right: 28,
                                          child: Text(
                                            page.number,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: paleGreen.withValues(
                                                alpha: 0.65,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: compact ? 20 : 32),

                                // PAGE EYEBROW
                                Text(
                                  page.eyebrow,
                                  style: const TextStyle(
                                    color: lime,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // PAGE TITLE
                                Text(
                                  page.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 29 : 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.2,
                                    height: 1.12,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // PAGE DESCRIPTION
                                Text(
                                  page.description,
                                  style: const TextStyle(
                                    color: paleGreen,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // PROGRESS INDICATORS
              Row(
                children: [
                  Row(
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 7),
                        width: _currentPage == index ? 29 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? lime
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: const TextStyle(
                      color: paleGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: forest,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Get started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Icon(Icons.arrow_forward_rounded, size: 21),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Simple checks. Smarter choices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: paleGreen,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ONBOARDING PAGE CONTENT MODEL
class _OnboardingPageData {
  final IconData icon;
  final String number;
  final String eyebrow;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}

// SMALL DECORATIVE CIRCLE
class _DecorativeDot extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
