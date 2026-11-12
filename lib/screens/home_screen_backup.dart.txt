import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'spoilage_alert_screen.dart';

// =====================================================
// FRESHTRACK - HOME DASHBOARD
// =====================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // =====================================================
  // NAVIGATION
  // =====================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _openGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen(openGallery: true)),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // =====================================================
  // SPOILAGE ALERT DEMO
  // =====================================================

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpoilageAlertScreen(
            imagePath: photo.path,
            produceName: 'Selected produce (demo)',
            confidence: 0.94,
            isDemo: true,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open photo: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =====================================================
  // HOME SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,

      // ===============================================
      // APP BAR
      // ===============================================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        toolbarHeight: 76,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: AppTheme.lime,
                size: 24,
              ),
            ),

            const SizedBox(width: 11),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'freshtrack.',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: AppTheme.forest,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'YOUR FRESHNESS COMPANION',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                _showComingSoon(context, 'Notifications');
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.forest,
              ),
            ),
          ),
        ],
      ),

      // ===============================================
      // MAIN CONTENT
      // ===============================================
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            // -----------------------------------------
            // GREETING
            // -----------------------------------------

            const Text(
              'WELCOME BACK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: AppTheme.muted,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Hello, there ✳',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: AppTheme.forest,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'A little check for a fresher day.',
              style: TextStyle(fontSize: 14, color: AppTheme.muted),
            ),

            const SizedBox(height: 28),

            // =========================================
            // MAIN FRESHNESS CHECK CARD
            // =========================================
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5EBDD),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Image.asset(
                          'assets/images/fresh_produce.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.sage,
                              child: const Center(
                                child: Icon(
                                  Icons.eco_rounded,
                                  color: AppTheme.forest,
                                  size: 85,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'YOUR DAILY FRESHNESS CHECK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Color(0xFF54705A),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.center_focus_strong_rounded,
                              color: AppTheme.forest,
                              size: 23,
                            ),
                          ],
                        ),

                        const SizedBox(height: 13),

                        const Text(
                          'Is your food still fresh?',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: AppTheme.forest,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Take a quick photo to explore '
                          'its freshness and visible quality.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: Color(0xFF587060),
                          ),
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _openCamera(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.forest,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(56),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 14,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 21),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Start a freshness check',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_outward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =========================================
            // GALLERY OPTION
            // =========================================
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openGallery(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppTheme.forest,
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose from gallery',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.forest,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Use a photo you've already taken",
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.forest,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================================
            // PROTOTYPE TESTING
            // =========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DEMO LABEL
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.sage,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'DEMO MODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: AppTheme.forest,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Preview a spoilage warning',
                    style: TextStyle(
                      color: AppTheme.forest,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Select a food photo to preview '
                    'the spoilage alert screen. '
                    'No actual prediction is performed.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // RESPONSIVE PREVIEW BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _previewSpoilageAlert(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA34439),
                        backgroundColor: const Color(0xFFFBE5E2),
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        side: const BorderSide(color: Color(0xFFF0CAC5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 21),

                          SizedBox(width: 11),

                          Expanded(
                            child: Text(
                              'Spoilage alert',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =========================================
            // RECENT ACTIVITY HEADER
            // =========================================
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent activity',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: AppTheme.forest,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Your latest freshness checks',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () => _openHistory(context),
                  child: const Text(
                    'See all',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =========================================
            // RECENT ACTIVITY DEMO RECORDS
            // =========================================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Column(
                children: [
                  FoodAssessmentTile(
                    name: 'Red Apple',
                    imagePath: 'assets/images/apple.jpg',
                    status: 'Fresh',
                    statusColor: Color(0xFF2D8051),
                    statusBackground: Color(0xFFE6F3E9),
                    fallbackIcon: Icons.apple,
                  ),

                  Divider(height: 26, color: Color(0xFFEDF0E9)),

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

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'Demo assessments • Not actual predictions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ),
          ],
        ),
      ),

      // ===============================================
      // BOTTOM NAVIGATION
      // ===============================================
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.sage,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            _openCamera(context);
          } else if (index == 2) {
            _openHistory(context);
          } else if (index == 3) {
            _openProfile(context);
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
            label: 'Check',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REUSABLE RECENT ACTIVITY TILE
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
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 56,
            height: 60,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.sage,
                  child: Icon(fallbackIcon, color: AppTheme.forest, size: 28),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forest,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Demo assessment',
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ],
          ),
        ),

        const SizedBox(width: 7),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
