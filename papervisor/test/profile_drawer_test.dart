import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papervisor/core/theme/theme_provider.dart';
import 'package:papervisor/features/workspace/constants/workspace_theme.dart';
import 'package:papervisor/features/workspace/widgets/profile_drawer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider & ProfileDrawer Tests', () {
    test('ThemeProvider switches theme mode and syncs WorkspaceTheme', () async {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.light);

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(WorkspaceTheme.isDark, isTrue);

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(WorkspaceTheme.isDark, isFalse);
    });

    testWidgets('ProfileDrawer renders all sections and triggers callbacks', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool logoutCalled = false;
      bool deleteCalled = false;

      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              endDrawer: ProfileDrawer(
                onLogout: () => logoutCalled = true,
                onDeleteProfile: () => deleteCalled = true,
              ),
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Educator Profile'), findsOneWidget);
      expect(find.text('Verified Educator'), findsNothing);

      // Check sections
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('Light'), findsNWidgets(2)); // header status badge + selector button
      expect(find.text('Dark'), findsOneWidget);

      expect(find.text('PRIVACY & INTEGRITY'), findsOneWidget);
      expect(find.text('Privacy & Academic Integrity'), findsOneWidget);

      expect(find.text('ACCOUNT ACTIONS'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.text('Delete Profile'), findsOneWidget);

      // Tap Theme Dark button
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(WorkspaceTheme.isDark, isTrue);

      // Tap Theme Light button
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(WorkspaceTheme.isDark, isFalse);

      // Tap Logout
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      expect(logoutCalled, isTrue);

      // Re-open drawer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Delete Profile
      await tester.tap(find.text('Delete Profile'));
      await tester.pumpAndSettle();
      expect(deleteCalled, isTrue);
    });
  });
}
