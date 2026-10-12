import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/hydration_provider.dart';
import '../widgets/aquasoothe_header.dart';
import '../widgets/glass_card.dart';
import 'auth_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _quietHoursEnabled = false;
  bool _caregiverSharingEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);
    final hydrationState = ref.watch(hydrationProvider);
    final isSi = settingsState.isSinhala;
    final currentScale = settingsState.textScaleFactor;
    final isDarkMode = settingsState.isDarkMode;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? const Color(0xFFE3F5F3) : const Color(0xFF0C4648);
    final subtitleColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final primaryTeal = isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648);
    final dividerColor = (isDark ? Colors.white : const Color(0xFF0C4648)).withValues(alpha: 0.1);

    final userName = user?.name.isNotEmpty == true ? user!.name : (isSi ? 'පරිශීලකයා' : 'AquaSoothe User');
    final userEmail = user?.email.isNotEmpty == true ? user!.email : (isSi ? 'අමුත්තෙකු ලෙස සම්බන්ධයි' : 'Guest Account');
    final initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

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
                  // App Header
                  const AquaSootheHeader(isCentered: false),

                  const SizedBox(height: 20),

                  // Screen Title
                  Text(
                    isSi ? 'පැතිකඩ සහ සැකසුම්' : 'Profile & Settings',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1. Hero Profile Card with Avatar & Details
                  GlassCard(
                    borderRadius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(22.0),
                    margin: EdgeInsets.zero,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF13272C).withValues(alpha: 0.85),
                              const Color(0xFF1E3A40).withValues(alpha: 0.75),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.90),
                              const Color(0xFFF0F9F8).withValues(alpha: 0.85),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar with glowing ring
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0C4648), Color(0xFF1E676B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0C4648).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initialLetter,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),

                            // Name & Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryTeal.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryTeal.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_user_rounded,
                                          size: 14,
                                          color: primaryTeal,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isSi ? 'සක්‍රිය ගිණුම' : 'Active Member',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: primaryTeal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Divider(height: 1, color: dividerColor),
                        const SizedBox(height: 14),

                        // Quick Wellness Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.water_drop_rounded,
                              iconColor: const Color(0xFF38B2AC),
                              label: isSi ? 'අද ජලය' : 'Today',
                              value: '${hydrationState.todayTotalMl} ml',
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Container(width: 1, height: 32, color: dividerColor),
                            _buildStatItem(
                              icon: Icons.flag_rounded,
                              iconColor: const Color(0xFFE53E3E),
                              label: isSi ? 'ඉලක්කය' : 'Goal',
                              value: '${hydrationState.goal.dailyTargetMl} ml',
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Container(width: 1, height: 32, color: dividerColor),
                            _buildStatItem(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: const Color(0xFFDD6B20),
                              label: isSi ? 'සති ඉලක්ක' : 'Active Days',
                              value: '${hydrationState.past7DaysTotals.values.where((v) => v > 0).length} / 7',
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Title: Settings (සැකසුම්)
                  Row(
                    children: [
                      Icon(Icons.settings_suggest_rounded, size: 22, color: primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        isSi ? 'යෙදුමේ සැකසුම් (Settings)' : 'App Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. Language Section Card
                  _buildSectionCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'භාෂාව' : 'Language',
                    icon: Icons.language_rounded,
                    children: [
                      _buildListTileItem(
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        title: 'English (United States)',
                        trailing: !isSi
                            ? Icon(Icons.check_circle_rounded, color: primaryTeal, size: 22)
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
                            ? Icon(Icons.check_circle_rounded, color: primaryTeal, size: 22)
                            : null,
                        onTap: () {
                          ref.read(settingsProvider.notifier).setLanguage('si');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. Appearance & Theme Card
                  _buildSectionCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'පෙනුම සහ තේමාව' : 'Appearance & Theme',
                    icon: Icons.dark_mode_rounded,
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
                        title: isSi ? 'අකුරු ප්‍රමාණය' : 'Text Size (Senior Friendly)',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentScale > 1.2
                                  ? '130%'
                                  : (currentScale > 1.1 ? '115%' : '100%'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
                          ],
                        ),
                        onTap: () {
                          _showTextSizeDialog(context, ref, currentScale, isSi);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Notifications & Reminders Card
                  _buildSectionCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'දැනුම්දීම් සහ සිහිකැඳවීම්' : 'Notifications & Reminders',
                    icon: Icons.notifications_active_rounded,
                    children: [
                      _buildSwitchTileItem(
                        textColor: textColor,
                        title: isSi ? 'නිහඬ වේලාවන් (Quiet Hours)' : 'Quiet Hours (Night Silence)',
                        value: _quietHoursEnabled,
                        onChanged: (val) {
                          setState(() => _quietHoursEnabled = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 5. Caregiver Connection Card
                  _buildSectionCard(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    title: isSi ? 'භාරකරු සම්බන්ධතාවය' : 'Caregiver Connection',
                    icon: Icons.favorite_rounded,
                    description: isSi
                        ? 'විශ්වාසවන්ත භාරකරුවෙකුට ඔබේ සෞඛ්‍ය ප්‍රගතිය බැලීමට ඉඩ දෙන්න.'
                        : 'Allow a trusted caregiver to monitor hydration progress.',
                    children: [
                      _buildSwitchTileItem(
                        textColor: textColor,
                        title: isSi ? 'හවුල් කිරීම සක්‍රිය කරන්න' : 'Enable Caregiver Sharing',
                        value: _caregiverSharingEnabled,
                        onChanged: (val) {
                          setState(() => _caregiverSharingEnabled = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Sign Out Button
                  Center(
                    child: GlassCard(
                      borderRadius: 18,
                      blur: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
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
                          const SizedBox(width: 10),
                          Text(
                            isSi ? 'ගිණුමෙන් පිටවීම' : 'Sign Out',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Color textColor,
    required Color subtitleColor,
    required String title,
    required IconData icon,
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
          Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
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
          const SizedBox(height: 12),
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
                fontSize: 15,
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
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
