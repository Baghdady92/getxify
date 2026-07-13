# GetXify

![GetXify](https://raw.githubusercontent.com/Aniketkhote/getxify/master/assets/getxify.png)

[![pub package](https://img.shields.io/pub/v/getxify?label=getxify&color=blue)](https://pub.dev/packages/getxify)
[![CI](https://github.com/Aniketkhote/getxify/actions/workflows/main.yml/badge.svg)](https://github.com/Aniketkhote/getxify/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/Aniketkhote/getxify/branch/master/graph/badge.svg)](https://codecov.io/gh/Aniketkhote/getxify)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)

**GetXify** is a modernized, actively maintained fork of [GetX](https://github.com/jonataslaw/getx) — an extra-light and powerful solution for Flutter. It brings high-performance state management, intelligent dependency injection, and route management while staying fully API-compatible with GetX.

---

## What's new in v4.0.0

v4.0.0 is a landmark release, contributed entirely by [@Baghdady92](https://github.com/Baghdady92), who resolved **111 issues** from the upstream GetX tracker and grew the test suite from 144 to **494 passing tests**. Key areas improved:

- **Routing & navigation** — `preventDuplicates`, nested `GetRouterOutlet`, middleware pipeline, browser back, predictive back, and deep links all fixed
- **System back & pop** — `PopScope` / `WillPopScope` / `canPop` respected on Android, Web, and iOS edge-swipe
- **Dependency injection** — deferred disposal, fenix registrations, route-scoped controllers, and `Get.putAsync` restored
- **State management** — `GetBuilder` tag changes, `RxList`/`RxSet`/`RxMap` default constructors, `bindStream` leak fixed
- **Dialogs, sheets & snackbars** — `Get.close()` result forwarding, idempotent `SnackbarController`, queue robustness
- **Reactive types** — `assign`/`assignAll` notify exactly once, unmodifiable backing collections handled
- **Internationalization** — `scriptCode` lookup, explicit locale vs device locale, CLDR plural categories

See the full [CHANGELOG](CHANGELOG.md) for details.

---

## Why GetXify over GetX?

| | GetX | GetXify |
|---|---|---|
| Dart SDK | legacy | ^3.12.2 |
| Flutter | legacy | >=3.44.2 |
| Deprecated APIs | present | removed |
| Test suite | 144 tests | 494 tests |
| Upstream bug fixes | — | 111 resolved |
| GetConnect (HTTP) | included | removed* |

\* Use `dio` or `http` instead — keeping GetXify focused on its core.

---

## Installation

```yaml
dependencies:
  getxify: ^4.0.0
```

```dart
import 'package:getxify/getxify.dart';
```

### Migrating from GetX

```dart
// Before
import 'package:get/get.dart';

// After
import 'package:getxify/getxify.dart';
```

That's it — the API is fully compatible. Also update your `pubspec.yaml`:

```yaml
# Before
dependencies:
  get: ...

# After
dependencies:
  getxify: ^4.0.0
```

---

## Quick start

```dart
void main() => runApp(GetMaterialApp(home: Home()));

class CounterController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
}

class Home extends StatelessWidget {
  final c = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Clicks: ${c.count}'))),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.to(OtherPage()),
          child: const Text('Go to Other'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: c.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OtherPage extends StatelessWidget {
  final c = Get.find<CounterController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Obx(() => Text('${c.count}'))));
  }
}
```

---

## Key features

- **State management** — reactive (`.obs` + `Obx`) and simple (`GetBuilder`) state managers
- **Route management** — named routes, nested navigation, middleware, transitions, deep links
- **Dependency injection** — smart lifecycle-aware DI with `Get.put`, `Get.lazyPut`, `Get.find`, bindings
- **Internationalization** — `.tr` translations with CLDR plural support
- **Theme management** — light/dark theme switching without rebuilding the tree
- **Platform utilities** — `GetPlatform`, responsive breakpoints, context extensions

---

## Example app

A full example app is in the `example/` directory, demonstrating:

- Nested routing with `GetRouterOutlet`
- Route guards (`EnsureAuthMiddleware`, `EnsureNotAuthedMiddleware`)
- Named routes with type-safe `Routes` class
- Dynamic route parameters
- Page transitions
- Reactive state with `.obs`
- `GetxService` for global state
- Lazy bindings

```bash
cd example
flutter pub get
flutter run
```

---

## Breaking changes from GetX

**v4.0.0**
- `Get.back()` now returns `bool` — callers ignoring the result are unaffected
- iOS back-swipe starts only near the leading edge by default — use `popGesture: true` to restore full-screen

**v2.0.0**
- Removed `GetUtils` validation/string helpers — use [`validators`](https://pub.dev/packages/validators) or [`recase`](https://pub.dev/packages/recase)
- Removed several extensions (`double_extensions`, `duration_extensions`, `widget_extensions`, etc.)

**v1.0.0**
- Removed `GetConnect` HTTP/WebSocket module — use [`dio`](https://pub.dev/packages/dio) or [`http`](https://pub.dev/packages/http)
- Removed mini stream utilities — use standard Dart streams or [`rxdart`](https://pub.dev/packages/rxdart)
- All deprecated GetX APIs removed

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, coding standards, and the PR workflow.

## License

GetXify is released under the MIT License. See [LICENSE](LICENSE) for details.  
Includes work by [@Baghdady92](https://github.com/Baghdady92) and originally forked from [GetX](https://github.com/jonataslaw/getx) by Jonatas Borges.
