import 'package:flutter/material.dart';

import 'home_screen.dart';

// ==========================================
// FRESHTRACK ONBOARDING SCREEN
// ==========================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Application colours
  static const Color darkGreen = Color(0xFF003D2E);
  static const Color sageGreen = Color(0xFF9AB5A8);
  static const Color background = Color(0xFFF8F9FC);
  static const Color paleBlue = Color(0xFFE6F0F1);

  // Tracks the current onboarding page
  int currentPage = 0;

  // Controls the onboarding pages
  final PageController pageController = PageController();

  // Content for the three onboarding pages
  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.camera_alt_outlined,
      'title': 'Check Your Food Freshness',
      'description':
          'Capture a photo of your fruits or vegetables '
          'to assess their freshness.',
    },
    {
      'icon': Icons.eco_outlined,
      'title': 'Understand Food Quality',
      'description':
          'Identify visible signs of spoilage and '
          'learn more about your food.',
    },
    {
      'icon': Icons.verified_outlined,
      'title': 'Make Informed Decisions',
      'description':
          'Get helpful freshness insights to support '
          'better food handling decisions.',
    },
  ];

  // ==========================================
  // NAVIGATION FUNCTIONS
  // ==========================================

  // Moves to the next onboarding page
  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      openHomeScreen();
    }
  }

  // Opens the Home Dashboard
  void openHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // Releases the PageController when leaving the screen
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // ==========================================
  // BUILD ONBOARDING INTERFACE
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // TOP APP BAR
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          'FreshTrack',
          style: TextStyle(
            color: darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed: openHomeScreen,
            child: const Text(
              'Skip',
              style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      // MAIN CONTENT
      body: SafeArea(
        child: Column(
          children: [
            // SWIPEABLE ONBOARDING PAGES
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ILLUSTRATION AREA
                        Container(
                          width: 220,
                          height: 220,

                          decoration: BoxDecoration(
                            color: paleBlue,
                            borderRadius: BorderRadius.circular(24),
                          ),

                          child: Icon(
                            page['icon'] as IconData,
                            size: 100,
                            color: darkGreen,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ONBOARDING TITLE
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF20252B),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ONBOARDING DESCRIPTION
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF667078),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // PROGRESS INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentPage == index ? 24 : 8,

                  decoration: BoxDecoration(
                    color: currentPage == index ? darkGreen : sageGreen,

                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: nextPage,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        currentPage == pages.length - 1
                            ? 'Get Started'
                            : 'Continue',

                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(Icons.arrow_forward, size: 19),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        selectedIndex: 1,
        indicatorColor: darkGreen,

        onDestinationSelected: (index) {
          // Home button opens the Home Dashboard
          if (index == 0) {
            openHomeScreen();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This feature is coming soon!')),
            );
          }
        },

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),

          NavigationDestination(
            icon: Icon(Icons.center_focus_strong),
            label: 'Check',
          ),

          NavigationDestination(icon: Icon(Icons.history), label: 'History'),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
