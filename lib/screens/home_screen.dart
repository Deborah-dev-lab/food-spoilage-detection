import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'spoilage_alert_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color forest = AppTheme.forest;
  static const Color lime = Color(0xFFC6F0A5);
  static const Color canvas = Color(0xFFF7F8F4);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color muted = AppTheme.muted;
  static const Color border = AppTheme.border;

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

  Future<void> _previewSpoilageAlert(BuildContext context) async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (photo == null || !context.mounted) return;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open photo: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildGreeting(),
            const SizedBox(height: 25),
            _buildScanCard(context),
            const SizedBox(height: 15),
            _buildQuickActions(context),
            const SizedBox(height: 30),
            _buildRecentActivity(context),
            const SizedBox(height: 24),
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
      bottomNavigationBar: NavigationBarTheme(
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.eco_rounded, color: forest, size: 28),
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
          'Your everyday space for smarter food choices.',
          style: TextStyle(color: muted, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRESHNESS CHECK',
                      style: TextStyle(
                        color: lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Check your\nproduce.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 11),
                    Text(
                      'Take a photo to explore visible signs '
                      'of freshness or spoilage.',
                      style: TextStyle(color: sage, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: lime.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.center_focus_strong_rounded,
                  color: lime,
                  size: 35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _openCamera(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: forest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 21),
                  SizedBox(width: 10),
                  Text(
                    'Start a scan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  letterSpacing: -0.5,
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
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ),
      ],
    );
  }

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
              'A photo can reveal visible spoilage, but it '
              'cannot guarantee food safety.',
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
}

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
                  color: AppTheme.sage,
                  child: Icon(fallbackIcon, color: AppTheme.forest, size: 27),
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
                  color: AppTheme.forest,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Sample assessment',
                style: TextStyle(color: AppTheme.muted, fontSize: 11),
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
