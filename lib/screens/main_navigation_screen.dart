import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'sounds_library_screen.dart';
import 'hydration_screen.dart';
import 'settings_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/mini_audio_player_bar.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    SoundsLibraryScreen(),
    HydrationScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      Future.microtask(() {
        ref.read(navigationTabProvider.notifier).state = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationTabProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = isDark ? const Color(0xFF13272C) : Colors.white;
    final indicatorColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648);
    final selectedIconColor = isDark ? const Color(0xFF0B191C) : Colors.white;
    final unselectedIconColor = isDark ? const Color(0xFF88ACAA) : const Color(0xFF5B787A);
    final selectedLabelColor = isDark ? const Color(0xFF70D6CE) : const Color(0xFF0C4648);
    final borderColor = isDark ? const Color(0xFF1E3A40) : const Color(0xFFE2EFEF);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayerBar(),
          Theme(
            data: theme.copyWith(
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: navBg,
                indicatorColor: indicatorColor,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(color: selectedIconColor, size: 24);
                  }
                  return IconThemeData(color: unselectedIconColor, size: 22);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selectedLabelColor,
                    );
                  }
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: unselectedIconColor,
                  );
                }),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: navBg,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  ref.read(navigationTabProvider.notifier).state = index;
                },
                elevation: 0,
                height: 68,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.waves_outlined),
                    selectedIcon: Icon(Icons.waves_rounded),
                    label: 'Sounds',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.water_drop_outlined),
                    selectedIcon: Icon(Icons.water_drop_rounded),
                    label: 'Hydration',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
