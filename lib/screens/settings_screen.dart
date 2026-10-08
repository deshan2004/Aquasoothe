import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/aquasoothe_header.dart';
import 'auth_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _quietHoursEnabled = false;
  bool _caregiverSharingEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);
    final currentScale = settingsState.textScaleFactor;
    final isDarkMode = settingsState.isDarkMode;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF13272C) : const Color(0xFFE8F6F4);
    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final dividerColor = isDark ? const Color(0xFF1E3A40) : const Color(0xFFD6EBE8);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              const AquaSootheHeader(isCentered: false),

              const SizedBox(height: 28),

              // Title
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 24),

              // 1. Profile Section Card
              _buildSettingsCard(
                cardBg: cardBg,
                textColor: textColor,
                title: 'Profile',
                children: [
                  _buildListTileItem(
                    textColor: textColor,
                    title: 'Account Details',
                    onTap: () {
                      _showAccountDetailsDialog(context, user);
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildListTileItem(
                    textColor: textColor,
                    title: 'Personal Information',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Notifications Section Card
              _buildSettingsCard(
                cardBg: cardBg,
                textColor: textColor,
                title: 'Notifications',
                children: [
                  _buildListTileItem(
                    textColor: textColor,
                    title: 'Hydration Reminders',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildSwitchTileItem(
                    textColor: textColor,
                    title: 'Quiet Hours',
                    value: _quietHoursEnabled,
                    onChanged: (val) {
                      setState(() => _quietHoursEnabled = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Caregiver Connection Section Card
              _buildSettingsCard(
                cardBg: cardBg,
                textColor: textColor,
                title: 'Caregiver Connection',
                description: 'Allow a trusted caregiver to view your hydration progress.',
                children: [
                  _buildSwitchTileItem(
                    textColor: textColor,
                    title: 'Enable Sharing',
                    value: _caregiverSharingEnabled,
                    onChanged: (val) {
                      setState(() => _caregiverSharingEnabled = val);
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildListTileItem(
                    textColor: textColor,
                    title: 'Manage Caregivers',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 4. Appearance & Bedtime Dark Mode Section Card
              _buildSettingsCard(
                cardBg: cardBg,
                textColor: textColor,
                title: 'Appearance & Bedtime Theme',
                children: [
                  _buildSwitchTileItem(
                    textColor: textColor,
                    title: 'Bedtime Dark Mode',
                    value: isDarkMode,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setDarkMode(val);
                    },
                  ),
                  Divider(height: 1, color: dividerColor),
                  _buildListTileItem(
                    textColor: textColor,
                    title: 'Text Size',
                    onTap: () {
                      _showTextSizeDialog(context, ref, currentScale);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sign Out Button
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color cardBg,
    required Color textColor,
    required String title,
    String? description,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF88ACAA),
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildListTileItem({
    required Color textColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF88ACAA),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTileItem({
    required Color textColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF70D6CE),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF32545A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showAccountDetailsDialog(BuildContext context, user) {
    final isLoggedIn = user != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Account Details', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${isLoggedIn ? user.name : "Guest User"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Email: ${isLoggedIn ? user.email : "guest@aquasoothe.app"}', style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, WidgetRef ref, double current) {
    final sizes = [
      {'label': 'Normal (100%)', 'val': 1.0},
      {'label': 'Large (125%)', 'val': 1.25},
      {'label': 'Extra Large (150%)', 'val': 1.5},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Text Display Size', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((opt) {
            final val = opt['val'] as double;
            final isSelected = (current - val).abs() < 0.05;
            return ListTile(
              title: Text(opt['label'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0C4648)) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setTextScaleFactor(val);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
