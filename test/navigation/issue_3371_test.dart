import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'rebuilding GetMaterialApp with a new theme updates the MaterialApp theme',
    (tester) async {
      const firstColor = Color(0xFF123456);
      const secondColor = Color(0xFF654321);

      final themeNotifier = ValueNotifier<ThemeData>(
        ThemeData(primaryColor: firstColor),
      );
      addTearDown(themeNotifier.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeData>(
          valueListenable: themeNotifier,
          builder: (context, themeData, _) {
            return GetMaterialApp(
              theme: themeData,
              getPages: [GetPage(name: '/', page: () => const Home())],
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.byType(Home));
      expect(Theme.of(homeContext).primaryColor, firstColor);

      themeNotifier.value = ThemeData(primaryColor: secondColor);
      await tester.pumpAndSettle();

      final updatedContext = tester.element(find.byType(Home));
      expect(Theme.of(updatedContext).primaryColor, secondColor);
    },
  );

  testWidgets(
    'rebuilding GetMaterialApp with a new themeMode switches light/dark',
    (tester) async {
      final modeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
      addTearDown(modeNotifier.dispose);

      final lightTheme = ThemeData(brightness: Brightness.light);
      final darkTheme = ThemeData(brightness: Brightness.dark);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: modeNotifier,
          builder: (context, mode, _) {
            return GetMaterialApp(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: mode,
              getPages: [GetPage(name: '/', page: () => const Home())],
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.byType(Home));
      expect(Theme.of(homeContext).brightness, Brightness.light);

      modeNotifier.value = ThemeMode.dark;
      await tester.pumpAndSettle();

      final updatedContext = tester.element(find.byType(Home));
      expect(Theme.of(updatedContext).brightness, Brightness.dark);
    },
  );

  testWidgets('Get.changeTheme still applies runtime theme changes', (
    tester,
  ) async {
    const startColor = Color(0xFF111111);
    const runtimeColor = Color(0xFF222222);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(primaryColor: startColor),
        getPages: [GetPage(name: '/', page: () => const Home())],
      ),
    );

    Get.changeTheme(ThemeData(primaryColor: runtimeColor));
    await tester.pumpAndSettle();

    final homeContext = tester.element(find.byType(Home));
    expect(Theme.of(homeContext).primaryColor, runtimeColor);
  });
}
