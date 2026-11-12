import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'learning_hub_screen.dart';
import 'vendor/vendor_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = false;

  void _openVendorWorkspace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _openLearningHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LearningHubScreen()),
    );
  }

  void _showInformation({required String title, required String content}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.75,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppTheme.forest,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 25),
                    child: Text(
                      content,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNotificationPreferences() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification preferences',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Preview your reminder preferences. '
                      'Notifications are not active yet.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _notificationsEnabled,
                      activeTrackColor: AppTheme.forest,
                      title: const Text(
                        'Enable reminders',
                        style: TextStyle(
                          color: AppTheme.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text('Preference preview only'),
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'This setting is temporary and resets '
                      'when the app restarts. No notifications '
                      'will be scheduled.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openHistoryManagement() {
    _showInformation(
      title: 'History management',
      content:
          'Assessment history will be stored locally '
          'when the database is integrated.\n\n'
          'You will then be able to review saved '
          'assessments, delete individual records '
          'and clear your history.\n\n'
          'The current History screen uses '
          'demonstration entries.',
    );
  }

  void _openAbout() {
    _showInformation(
      title: 'About FreshTrack',
      content:
          'FreshTrack is a smartphone-based food '
          'freshness and spoilage assessment application '
          'developed as an academic project.\n\n'
          'It uses computer vision and a convolutional '
          'neural network (CNN) to analyse visible '
          'patterns in supported fruits and vegetables.\n\n'
          'The current Android prototype includes '
          'on-device TensorFlow Lite inference, '
          'household assessment screens and a '
          'vendor workspace.\n\n'
          'FreshTrack is designed with offline '
          'accessibility in mind, particularly for '
          'households and small-scale produce vendors.\n\n'
          'The model is experimental and may produce '
          'incorrect classifications. A visual assessment '
          'cannot confirm that food is safe to consume.',
    );
  }

  void _openHelp() {
    _showInformation(
      title: 'Help & FAQs',
      content:
          'How do I assess produce?\n'
          'Open Scan Produce, capture or select a clear '
          'photograph, review the image and continue '
          'to the assessment.\n\n'
          'What does the model score mean?\n'
          'The score indicates how strongly the model '
          'favours its predicted class. It is not '
          'a calibrated probability of correctness '
          'or a guarantee of food safety.\n\n'
          'What if the result is uncertain?\n'
          'Try another clear image with good lighting '
          'and inspect the produce manually.\n\n'
          'Can FreshTrack detect bacteria or toxins?\n'
          'No. A smartphone photograph cannot reliably '
          'identify invisible pathogens, toxins '
          'or other contamination.\n\n'
          'How do I use Vendor Mode?\n'
          'Open Vendor Workspace to access stock entry, '
          'inventory, assessments and handling guidance. '
          'Stock records currently use prototype data.\n\n'
          'Where can I learn more about food handling?\n'
          'Open Learn & Explore for offline articles '
          'about food safety and value addition.\n\n'
          'Does FreshTrack work offline?\n'
          'The integrated CNN is designed to run '
          'on-device. Persistent offline storage '
          'will be added during database integration.',
    );
  }

  void _openPrivacy() {
    _showInformation(
      title: 'Privacy & data',
      content:
          'FreshTrack is currently an academic prototype.\n\n'
          'The application uses on-device image processing '
          'for its TensorFlow Lite assessment workflow. '
          'This does not require uploading an image '
          'to a cloud inference service.\n\n'
          'Local database storage for inventory, '
          'assessment history and feedback has not '
          'yet been implemented.\n\n'
          'A complete privacy review will be carried '
          'out before release, including image retention, '
          'local storage, permissions and deletion controls.\n\n'
          'Avoid including personal or sensitive '
          'information in assessment photographs.',
    );
  }

  Widget _sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppTheme.sage,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.forest, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.forest,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 65,
                endIndent: 16,
                color: AppTheme.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _vendorCard() {
    return Material(
      color: AppTheme.forest,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: _openVendorWorkspace,
        borderRadius: BorderRadius.circular(23),
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: AppTheme.lime,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
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
                      'Vendor workspace',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage produce stock and explore '
                      'handling recommendations.',
                      style: TextStyle(
                        color: Color(0xFFC8DACD),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.lime,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        foregroundColor: AppTheme.forest,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile & settings',
          style: TextStyle(
            color: AppTheme.forest,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
          children: [
            const Text(
              'YOUR SPACE',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Made for your\nfreshness journey.',
              style: TextStyle(
                color: AppTheme.forest,
                fontSize: 29,
                fontWeight: FontWeight.w800,
                height: 1.13,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 23),

            // GUEST PROFILE
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: AppTheme.lime,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.forest,
                      size: 31,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FreshTrack User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Local guest profile • No account required',
                          style: TextStyle(
                            color: Color(0xFFC8DACD),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.eco_outlined, color: AppTheme.lime),
                ],
              ),
            ),

            const SizedBox(height: 27),

            _sectionHeading('VENDOR MODE'),
            _vendorCard(),

            const SizedBox(height: 28),

            _sectionHeading('PREFERENCES'),
            _settingsGroup([
              _settingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notification preferences',
                subtitle: 'Preview future reminders',
                onTap: _openNotificationPreferences,
              ),
              _settingsTile(
                icon: Icons.history_rounded,
                title: 'Assessment history',
                subtitle: 'View previous food checks',
                onTap: _openHistory,
              ),
              _settingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'History management',
                subtitle: 'Future storage and deletion controls',
                onTap: _openHistoryManagement,
              ),
            ]),

            const SizedBox(height: 28),

            _sectionHeading('LEARNING & RESOURCES'),
            _settingsGroup([
              _settingsTile(
                icon: Icons.menu_book_outlined,
                title: 'Learn & Explore',
                subtitle: 'Food safety and value addition articles',
                onTap: _openLearningHub,
              ),
            ]),

            const SizedBox(height: 28),

            _sectionHeading('INFORMATION'),
            _settingsGroup([
              _settingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About FreshTrack',
                subtitle: 'Learn about the project',
                onTap: _openAbout,
              ),
              _settingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & FAQs',
                subtitle: 'How to use the application',
                onTap: _openHelp,
              ),
              _settingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & data',
                subtitle: 'Understand how data is handled',
                onTap: _openPrivacy,
              ),
            ]),

            const SizedBox(height: 32),

            const Center(
              child: Column(
                children: [
                  Icon(Icons.spa_outlined, size: 26, color: AppTheme.forest),
                  SizedBox(height: 8),
                  Text(
                    'FreshTrack',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forest,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Academic prototype • Version 1.0',
                    style: TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'A fresher way to make informed choices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
