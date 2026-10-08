import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquasoothe/main.dart';
import 'package:aquasoothe/providers/hydration_provider.dart';

void main() {
  testWidgets('AquaSoothe app initial smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AquaSootheApp(),
      ),
    );

    // Verify Onboarding Welcome title appears
    expect(find.textContaining('AquaSoothe'), findsWidgets);
  });
}
