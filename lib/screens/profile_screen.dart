import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = false;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.forest,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
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
                      'Choose whether you would like '
                      'to receive FreshTrack reminders '
                      'when notification support is added.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      value: _notificationsEnabled,
                      activeTrackColor: AppTheme.forest,
                      title: const Text(
                        'Enable reminders',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forest,
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
                    const SizedBox(height: 12),
                    const Text(
                      'Notifications are not active yet. '
                      'This setting is not saved after '
                      'the app restarts.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 1.5,
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

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _openHistoryManagement() {
    _showInformation(
      title: 'History management',
      content:
          'Your assessment history will be stored '
          'locally on your device once the storage '
          'feature is implemented.\n\n'
          'You will be able to review and delete '
          'individual assessments or clear your '
          'saved history.\n\n'
          'The records currently displayed in '
          'FreshTrack are demonstration entries, '
          'not actual saved assessments.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile & settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.forest,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'YOUR SPACE',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
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
            const SizedBox(height: 24),

            // USER PROFILE
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
                          'Local guest profile',
                          style: TextStyle(
                            color: Color(0xFFC8DACD),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.eco_outlined, color: AppTheme.lime),
                ],
              ),
            ),

            const SizedBox(height: 29),

            const _SectionHeading('PREFERENCES'),
            const SizedBox(height: 12),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification preferences',
                  subtitle: 'Manage future reminders',
                  onTap: _openNotificationPreferences,
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.history_rounded,
                  title: 'Assessment history',
                  subtitle: 'View previous food checks',
                  onTap: _openHistory,
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'History management',
                  subtitle: 'Manage saved assessments',
                  onTap: _openHistoryManagement,
                ),
              ],
            ),

            const SizedBox(height: 28),

            const _SectionHeading('INFORMATION'),
            const SizedBox(height: 12),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About FreshTrack',
                  subtitle: 'Learn about this project',
                  onTap: () {
                    _showInformation(
                      title: 'About FreshTrack',
                      content:
                          'FreshTrack is a smartphone-based '
                          'food spoilage detection application '
                          'developed as an academic project.\n\n'
                          'The system is designed to use '
                          'computer vision and a convolutional '
                          'neural network (CNN) to classify '
                          'visible freshness and spoilage '
                          'patterns in supported fruits '
                          'and vegetables.\n\n'
                          'Its objective is to provide '
                          'accessible food quality guidance '
                          'using smartphone photographs, '
                          'including in low-resource settings.\n\n'
                          'The CNN model has not yet been '
                          'integrated into this interface.',
                    );
                  },
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQs',
                  subtitle: 'How to use the application',
                  onTap: () {
                    _showInformation(
                      title: 'Help & FAQs',
                      content:
                          'How do I assess my food?\n'
                          'Open the Check screen, take a '
                          'clear photograph or select an '
                          'existing image, then review it '
                          'before continuing.\n\n'
                          'What does the confidence score mean?\n'
                          'It indicates how strongly the '
                          'model favours a classification. '
                          'It is not a guarantee of safety.\n\n'
                          'Can FreshTrack detect bacteria?\n'
                          'No. Image-based assessment cannot '
                          'reliably detect invisible bacteria, '
                          'toxins or other contamination.\n\n'
                          'Does the app work offline?\n'
                          'Offline assessment is a project '
                          'goal. It will depend on the final '
                          'model integration and local storage.',
                    );
                  },
                ),
                const _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & data',
                  subtitle: 'How your information is handled',
                  onTap: () {
                    _showInformation(
                      title: 'Privacy & data',
                      content:
                          'FreshTrack is currently an '
                          'academic prototype.\n\n'
                          'The current image-selection '
                          'workflow displays photographs '
                          'chosen or captured on your device. '
                          'No cloud upload feature has been '
                          'implemented in the Flutter screens '
                          'created so far.\n\n'
                          'Actual image retention, local '
                          'history storage and data deletion '
                          'controls will be defined and tested '
                          'when persistence is implemented.\n\n'
                          'Avoid including personal or '
                          'sensitive information in '
                          'assessment photographs.',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 34),

            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.spa_outlined,
                    size: 26,
                    color: AppTheme.forest,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FreshTrack',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Academic prototype • Version 1.0',
                    style: TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 6),
                  const Text(
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

// =====================================================
// REUSABLE COMPONENTS
// =====================================================

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.muted,
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 62,
      endIndent: 16,
      color: AppTheme.border,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: AppTheme.sage,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: AppTheme.forest),
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
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.muted,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
