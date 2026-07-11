import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class HomeController extends GetxController {}

class ProfileController extends GetxController {}

class HomeBinding extends BindingsInterface<void> {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}

class ProfileBinding extends BindingsInterface<void> {
  @override
  void dependencies() {
    Get.put(ProfileController());
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('profile'));
  }
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    "the parent page's binding runs when the first route is a child page",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home/profile',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const HomeView(),
              binding: HomeBinding(),
              children: [
                GetPage(
                  name: '/profile',
                  page: () => const ProfileView(),
                  binding: ProfileBinding(),
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfileView), findsOneWidget);
      // The child's own binding ran...
      expect(Get.find<ProfileController>(), isA<ProfileController>());
      // ...and so did the parent's, even though the parent page itself was
      // never visited.
      expect(Get.find<HomeController>(), isA<HomeController>());
    },
  );

  test('child pages inherit parent bindings, parents first', () {
    final homeBinding = HomeBinding();
    final profileBinding = ProfileBinding();
    final tree = ParseRouteTree(routes: <GetPage>[]);
    tree.addRoute(
      GetPage(
        name: '/home',
        page: () => const HomeView(),
        binding: homeBinding,
        children: [
          GetPage(
            name: '/profile',
            page: () => const ProfileView(),
            binding: profileBinding,
          ),
        ],
      ),
    );

    final bindings = tree.matchRoute('/home/profile').route!.bindings;
    expect(bindings, contains(homeBinding));
    expect(bindings, contains(profileBinding));
    expect(
      bindings.indexOf(homeBinding),
      lessThan(bindings.indexOf(profileBinding)),
    );
  });
}
