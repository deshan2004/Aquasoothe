import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'sounds_library_screen.dart';
import 'hydration_screen.dart';
import 'profile_screen.dart';
import '../widgets/mini_audio_player_bar.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    SoundsLibraryScreen(),
    HydrationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final isSi = settingsState.isSinhala;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniAudioPlayerBar(),
              const SizedBox(height: 4),
              // Floating Frosted Glass Dock
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF13272C).withValues(alpha: 0.75)
                          : Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.65),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4648).withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, isSi ? 'මුල් පිටුව' : 'Home', isDark),
                        _buildNavItem(1, Icons.waves_outlined, Icons.waves_rounded, isSi ? 'ශබ්ද' : 'Sounds', isDark),
                        _buildNavItem(2, Icons.water_drop_outlined, Icons.water_drop_rounded, isSi ? 'ජලය' : 'Hydration', isDark),
                        _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, isSi ? 'පැතිකඩ' : 'Profile', isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 18 : 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1E676B).withValues(alpha: 0.45)
                          : const Color(0xFF0C4648).withValues(alpha: 0.12))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected
                      ? (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648))
                      : (isDark ? Colors.white54 : const Color(0xFF7A8E91)),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? const Color(0xFF5ED1C7) : const Color(0xFF0C4648))
                      : (isDark ? Colors.white54 : const Color(0xFF7A8E91)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
