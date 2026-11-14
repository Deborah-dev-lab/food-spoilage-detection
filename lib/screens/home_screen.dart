import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'learning_hub_screen.dart';
import 'profile_screen.dart';
import 'spoilage_alert_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';

// =====================================================
// FRESHTRACK HOME SCREEN
// =====================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color canvas = Color(0xFFF7F8F4);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color muted = AppTheme.muted;
  static const Color border = AppTheme.border;

  // =====================================================
  // NAVIGATION
  // =====================================================

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openCamera(BuildContext context) {
    _openPage(context, const CameraScreen());
  }

  void _openGallery(BuildContext context) {
    _openPage(context, const CameraScreen(openGallery: true));
  }

  void _openHistory(BuildContext context) {
    _openPage(context, const HistoryScreen());
  }

  void _openProfile(BuildContext context) {
    _openPage(context, const ProfileScreen());
  }

  void _openVendor(BuildContext context) {
    _openPage(context, const VendorDashboardScreen());
  }

  void _openLearning(BuildContext context, {String category = 'All'}) {
    _openPage(context, LearningHubScreen(initialCategory: category));
  }

  Future<void> _previewSpoilageAlert(BuildContext context) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (photo == null || !context.mounted) {
        return;
      }

      _openPage(
        context,
        SpoilageAlertScreen(
          imagePath: photo.path,
          produceName: 'Selected produce (demo)',
          confidence: 0.94,
          isDemo: true,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open photo: $error')));
    }
  }

  // =====================================================
  // MAIN LAYOUT
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            _buildHeader(context),

            const SizedBox(height: 28),

            _buildGreeting(),

            const SizedBox(height: 23),

            _buildHeroCard(context),

            const SizedBox(height: 16),

            _buildQuickActions(context),

            const SizedBox(height: 30),

            _buildSectionHeading(
              title: 'Explore FreshTrack',
              subtitle: 'More ways to care for your produce.',
            ),

            const SizedBox(height: 15),

            _buildVendorCard(context),

            const SizedBox(height: 30),

            _buildLearningSection(context),

            const SizedBox(height: 30),

            _buildRecentActivity(context),

            const SizedBox(height: 22),

            _buildSafetyTip(),

            const SizedBox(height: 15),

            Center(
              child: TextButton.icon(
                onPressed: () => _previewSpoilageAlert(context),
                icon: const Icon(Icons.science_outlined, size: 17),
                label: const Text(
                  'Preview spoilage alert (demo)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.eco_rounded, color: forest, size: 29),

        const SizedBox(width: 8),

        const Expanded(
          child: Text(
            'freshtrack.',
            style: TextStyle(
              color: forest,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
            ),
          ),
        ),

        IconButton(
          tooltip: 'Open profile',
          onPressed: () => _openProfile(context),
          icon: const Icon(Icons.person_outline_rounded, color: forest),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: border),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // GREETING
  // =====================================================

  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR FRESHNESS COMPANION',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),

        SizedBox(height: 9),

        Text(
          "Hello, let's check\nwhat's fresh.",
          style: TextStyle(
            color: forest,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1.15,
          ),
        ),

        SizedBox(height: 10),

        Text(
          'Your everyday space for smarter '
          'food choices and better produce care.',
          style: TextStyle(color: muted, fontSize: 13, height: 1.55),
        ),
      ],
    );
  }

  // =====================================================
  // HERO — FOOD SPOILAGE IMAGE
  // =====================================================

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: const _LocalImage(
              imagePath: 'assets/images/learning/food_spoilage.jpg',
              height: 190,
              fallbackIcon: Icons.eco_rounded,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FRESHNESS CHECK',
                  style: TextStyle(
                    color: lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Know your produce\nbetter.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Take a photo to explore visible '
                  'signs of freshness or spoilage.',
                  style: TextStyle(color: sage, fontSize: 12, height: 1.5),
                ),

                const SizedBox(height: 21),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCamera(context),

                    icon: const Icon(Icons.camera_alt_outlined, size: 21),

                    label: const Text('Start a scan'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: lime,
                      foregroundColor: forest,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // QUICK ACTIONS
  // =====================================================

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_photo_alternate_outlined,
            title: 'Upload photo',
            subtitle: 'Choose from gallery',
            onTap: () => _openGallery(context),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _QuickActionCard(
            icon: Icons.history_rounded,
            title: 'Scan history',
            subtitle: 'Previous checks',
            onTap: () => _openHistory(context),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SECTION HEADING
  // =====================================================

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: forest,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  // =====================================================
  // VENDOR CARD — FOOD WASTE IMAGE
  // =====================================================

  Widget _buildVendorCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),

      child: InkWell(
        onTap: () => _openVendor(context),
        borderRadius: BorderRadius.circular(22),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(21),
                ),
                child: const _LocalImage(
                  imagePath: 'assets/images/learning/food_waste.jpg',
                  height: 150,
                  fallbackIcon: Icons.storefront_outlined,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(17),

                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are you a produce vendor?',
                            style: TextStyle(
                              color: forest,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Access your vendor workspace '
                            'and manage your produce.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: forest,
                      size: 23,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // LEARN & EXPLORE
  // =====================================================

  Widget _buildLearningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Learn & Explore',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            TextButton(
              onPressed: () => _openLearning(context),
              child: const Text(
                'View all',
                style: TextStyle(color: forest, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        const Text(
          'Simple tips to help you store, handle '
          'and care for your produce.',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LearningCard(
                title: 'Food Storage',
                subtitle: 'Keep produce fresh for longer.',
                imagePath: 'assets/images/learning/food_storage.jpg',
                fallbackIcon: Icons.kitchen_outlined,
                onTap: () => _openLearning(context),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _LearningCard(
                title: 'Food Hygiene',
                subtitle: 'Better handling and hygiene.',
                imagePath: 'assets/images/learning/food_hygiene.jpg',
                fallbackIcon: Icons.health_and_safety_outlined,
                onTap: () => _openLearning(context, category: 'Food Safety'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,

          child: OutlinedButton.icon(
            onPressed: () => _openLearning(context),

            icon: const Icon(Icons.menu_book_outlined),

            label: const Text('Explore all articles'),

            style: OutlinedButton.styleFrom(
              foregroundColor: forest,
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // RECENT ACTIVITY
  // =====================================================

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent activity',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            TextButton(
              onPressed: () => _openHistory(context),

              child: const Text(
                'View all',
                style: TextStyle(color: forest, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
          ),

          child: const Column(
            children: [
              FoodAssessmentTile(
                name: 'Red Apple',
                imagePath: 'assets/images/apple.jpg',
                status: 'Fresh',
                statusColor: Color(0xFF287C50),
                statusBackground: Color(0xFFE5F3E8),
                fallbackIcon: Icons.apple,
              ),

              Divider(height: 26, color: Color(0xFFE9EDE7)),

              FoodAssessmentTile(
                name: 'Banana',
                imagePath: 'assets/images/banana.jpg',
                status: 'Spoiling',
                statusColor: Color(0xFF9B6C26),
                statusBackground: Color(0xFFFFF0D8),
                fallbackIcon: Icons.eco_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 9),

        const Center(
          child: Text(
            'Sample assessments — not actual CNN predictions',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // FOOD SAFETY REMINDER
  // =====================================================

  Widget _buildSafetyTip() {
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: sage,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: forest, size: 25),

          SizedBox(width: 13),

          Expanded(
            child: Text(
              'A photograph can reveal visible '
              'spoilage, but it cannot guarantee '
              'food safety.',
              style: TextStyle(
                color: forest,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: sage,

        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? forest : muted,
            size: 24,
          );
        }),

        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected) ? forest : muted,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
          );
        }),
      ),

      child: NavigationBar(
        height: 72,
        selectedIndex: 0,

        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              _openCamera(context);
              break;

            case 2:
              _openHistory(context);
              break;

            case 3:
              _openProfile(context);
              break;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.center_focus_strong_rounded),
            label: 'Scan',
          ),

          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REUSABLE LOCAL IMAGE
// =====================================================

class _LocalImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final IconData fallbackIcon;

  const _LocalImage({
    required this.imagePath,
    required this.height,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,

      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: height,
          color: HomeScreen.sage,
          alignment: Alignment.center,

          child: Icon(fallbackIcon, color: HomeScreen.forest, size: 45),
        );
      },
    );
  }
}

// =====================================================
// QUICK ACTION CARD
// =====================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            border: Border.all(color: HomeScreen.border),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: HomeScreen.sage,
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: HomeScreen.forest, size: 23),
              ),

              const SizedBox(height: 14),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: HomeScreen.forest,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,

                style: const TextStyle(
                  color: HomeScreen.muted,
                  fontSize: 11,
                  height: 1.4,
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
// LEARNING CARD
// =====================================================

class _LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _LearningCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),

        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: HomeScreen.border),
            borderRadius: BorderRadius.circular(19),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),

                child: _LocalImage(
                  imagePath: imagePath,
                  height: 112,
                  fallbackIcon: fallbackIcon,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: HomeScreen.forest,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: HomeScreen.muted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
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
// RECENT ASSESSMENT TILE
// =====================================================

class FoodAssessmentTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final IconData fallbackIcon;

  const FoodAssessmentTile({
    super.key,
    required this.name,
    required this.imagePath,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),

          child: SizedBox(
            width: 57,
            height: 59,

            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: HomeScreen.sage,

                  child: Icon(fallbackIcon, color: HomeScreen.forest, size: 27),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: HomeScreen.forest,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Sample assessment',
                style: TextStyle(color: HomeScreen.muted, fontSize: 11),
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),

          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(30),
          ),

          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
