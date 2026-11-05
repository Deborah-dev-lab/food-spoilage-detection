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

  // All images are from the existing learning folder.
  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.camera_alt_outlined,
      imagePath: 'assets/images/learning/food_safety.jpg',
      number: '01',
      eyebrow: 'DISCOVER',
      title: 'Check your food\nfreshness.',
      description:
          'Capture or upload a photo of your fruits and vegetables '
          'to explore visible signs of freshness and spoilage.',
    ),
    _OnboardingPageData(
      icon: Icons.visibility_outlined,
      imagePath: 'assets/images/learning/food_spoilage.jpg',
      number: '02',
      eyebrow: 'UNDERSTAND',
      title: 'Know your\nproduce better.',
      description:
          'Explore image-based freshness assessments '
          'and learn to recognise possible signs of spoilage '
          'to support informed food handling decisions.',
    ),
    _OnboardingPageData(
      icon: Icons.menu_book_outlined,
      imagePath: 'assets/images/learning/value_addition.jpg',
      number: '03',
      eyebrow: 'LEARN & EXPLORE',
      title: 'Learn, preserve\nand reduce waste.',
      description:
          'Discover offline food safety articles, '
          'produce storage guidance and value addition '
          'ideas to help reduce avoidable food waste.',
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

  // =====================================================
  // ONBOARDING IMAGE
  // =====================================================

  Widget _buildImage(_OnboardingPageData page, bool compact) {
    final double imageHeight = compact ? 190 : 270;

    return SizedBox(
      width: double.infinity,
      height: imageHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: softGreen,
                    alignment: Alignment.center,
                    child: Icon(
                      page.icon,
                      color: lime,
                      size: compact ? 65 : 85,
                    ),
                  );
                },
              ),
            ),
          ),

          // Gradient for better contrast.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, forest.withValues(alpha: 0.5)],
                  ),
                ),
              ),
            ),
          ),

          // Small FreshTrack label.
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: forest.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_outlined, color: lime, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'FRESHTRACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page number.
          Positioned(
            right: 18,
            bottom: 15,
            child: Text(
              page.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INDIVIDUAL ONBOARDING PAGE
  // =====================================================

  Widget _buildPage(_OnboardingPageData page, BoxConstraints constraints) {
    final bool compact = constraints.maxHeight < 520;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(page, compact),

            SizedBox(height: compact ? 23 : 35),

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
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

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

              // SWIPEABLE ONBOARDING PAGES
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildPage(_pages[index], constraints);
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

              // CONTINUE / GET STARTED BUTTON
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

// =====================================================
// ONBOARDING PAGE DATA MODEL
// =====================================================

class _OnboardingPageData {
  final IconData icon;
  final String imagePath;
  final String number;
  final String eyebrow;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.imagePath,
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}
