import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/glass_card.dart';
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
    final isSi = settingsState.isSinhala;
    final currentScale = settingsState.textScaleFactor;
    final isDarkMode = settingsState.isDarkMode;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final dividerColor = (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aura Blobs
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF0C4648) : const Color(0xFFBDE4E1)).withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF163C42) : const Color(0xFFD5ECE7)).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8AB80).withValues(alpha: isDark ? 0.12 : 0.18),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logo
                  const AquaSootheHeader(isCentered: false),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isSi ? 'සැකසුම්' : 'Settings',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 1. Language Section Card (Single Language Isolation)
                  _buildSettingsCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'භාෂාව' : 'Language',
                    description: isSi ? 'යෙදුමේ භාෂාව තෝරන්න' : 'Choose application language',
                    children: [
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: 'English (United States)',
                        trailing: !isSi
                            ? Icon(Icons.check_circle_rounded, color: isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648), size: 22)
                            : null,
                        onTap: () {
                          ref.read(settingsProvider.notifier).setLanguage('en');
                        },
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: 'සිංහල (Sinhala)',
                        trailing: isSi
                            ? Icon(Icons.check_circle_rounded, color: isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648), size: 22)
                            : null,
                        onTap: () {
                          ref.read(settingsProvider.notifier).setLanguage('si');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. Appearance & Bedtime Dark Mode Section Card
                  _buildSettingsCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'පෙනුම සහ තේමාව' : 'Appearance & Bedtime Theme',
                    children: [
                      _buildSwitchTileItem(
                        textColor: textColor,
                        title: isSi ? 'අඳුරු තේමාව (Dark Mode)' : 'Bedtime Dark Mode',
                        value: isDarkMode,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).setDarkMode(val);
                        },
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: isSi ? 'අකුරු ප්‍රමාණය' : 'Text Size',
                        onTap: () {
                          _showTextSizeDialog(context, ref, currentScale, isSi);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. Profile Section Card
                  _buildSettingsCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'ගිණුම' : 'Profile',
                    children: [
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: isSi ? 'ගිණුමේ විස්තර' : 'Account Details',
                        onTap: () {
                          _showAccountDetailsDialog(context, user, isSi);
                        },
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: isSi ? 'පුද්ගලික තොරතුරු' : 'Personal Information',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Notifications Section Card
                  _buildSettingsCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'දැනුම්දීම්' : 'Notifications',
                    children: [
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: isSi ? 'ජල සිහිකැඳවීම්' : 'Hydration Reminders',
                        onTap: () {},
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildSwitchTileItem(
                        textColor: textColor,
                        title: isSi ? 'නිහඬ වේලාවන්' : 'Quiet Hours',
                        value: _quietHoursEnabled,
                        onChanged: (val) {
                          setState(() => _quietHoursEnabled = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 5. Caregiver Connection Section Card
                  _buildSettingsCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'භාරකරු සම්බන්ධතාවය' : 'Caregiver Connection',
                    description: isSi
                        ? 'විශ්වාසවන්ත භාරකරුවෙකුට ඔබේ ප්‍රගතිය බැලීමට ඉඩ දෙන්න.'
                        : 'Allow a trusted caregiver to view your hydration progress.',
                    children: [
                      _buildSwitchTileItem(
                        textColor: textColor,
                        title: isSi ? 'හවුල් කිරීම සක්‍රිය කරන්න' : 'Enable Sharing',
                        value: _caregiverSharingEnabled,
                        onChanged: (val) {
                          setState(() => _caregiverSharingEnabled = val);
                        },
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: isSi ? 'භාරකරුවන් කළමනාකරණය' : 'Manage Caregivers',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Frosted Glass Button
                  Center(
                    child: GlassCard(
                      borderRadius: 18,
                      blur: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      margin: EdgeInsets.zero,
                      borderColor: Colors.redAccent.withValues(alpha: 0.35),
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isSi ? 'පිටවීම' : 'Sign Out',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Space for floating bottom glass dock
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color textColor,
    required Color subtitleColor,
    required String title,
    String? description,
    required List<Widget> children,
  }) {
    return GlassCard(
      borderRadius: 22,
      blur: 16,
      padding: const EdgeInsets.all(20.0),
      margin: EdgeInsets.zero,
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
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTileItem({
    required Color textColor,
    required Color subtitleColor,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
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
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
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

  void _showAccountDetailsDialog(BuildContext context, dynamic user, bool isSi) {
    final isLoggedIn = user != null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isSi ? 'ගිණුමේ විස්තර' : 'Account Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${isSi ? "නම" : "Name"}: ${isLoggedIn ? user.name : (isSi ? "පරිශීලකයා" : "Guest User")}'),
            const SizedBox(height: 8),
            Text('${isSi ? "ඊමේල්" : "Email"}: ${isLoggedIn ? user.email : (isSi ? "සම්බන්ධ කර නැත" : "Not connected")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSi ? 'හරි' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, WidgetRef ref, double currentScale, bool isSi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isSi ? 'අකුරු ප්‍රමාණය තෝරන්න' : 'Select Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextSizeOption(
              ctx,
              ref,
              title: isSi ? 'සාමාන්‍ය (100%)' : 'Standard (100%)',
              scale: 1.0,
              isSelected: (currentScale - 1.0).abs() < 0.05,
            ),
            _buildTextSizeOption(
              ctx,
              ref,
              title: isSi ? 'විශාල (115% - වැඩිහිටියන්ට)' : 'Large (115% - Recommended)',
              scale: 1.15,
              isSelected: (currentScale - 1.15).abs() < 0.05,
            ),
            _buildTextSizeOption(
              ctx,
              ref,
              title: isSi ? 'ඉතා විශාල (130%)' : 'Extra Large (130%)',
              scale: 1.30,
              isSelected: (currentScale - 1.30).abs() < 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeOption(
    BuildContext ctx,
    WidgetRef ref, {
    required String title,
    required double scale,
    required bool isSelected,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0C4648)) : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setTextScaleFactor(scale);
        Navigator.pop(ctx);
      },
    );
  }
}
