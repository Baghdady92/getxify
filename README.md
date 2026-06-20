# GetXify

![GetXify](https://raw.githubusercontent.com/Aniketkhote/getxify/master/assets/getxify.png)

[![pub package](https://img.shields.io/pub/v/getxify?label=getxify&color=blue)](https://pub.dev/packages/getxify)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
<a href="https://github.com/Solido/awesome-flutter">
<img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

**GetXify** is an improved and enhanced version of GetX - an extra-light and powerful solution for Flutter. It combines high-performance state management, intelligent dependency injection, and route management quickly and practically.

## What is GetXify?

GetXify is a modernized fork of GetX that:

- **Supports latest Dart & Flutter** - Compatible with Dart SDK ^3.12.2 and Flutter >=3.44.2
- **Removes deprecated code** - Cleaned up all deprecated APIs and unused modules
- **Enhanced code quality** - Improved documentation, removed dead code, added safety checks
- **Updated APIs** - Aligned with latest Flutter APIs for BottomSheet, Snackbar, and Dialog
- **Better testing** - Expanded test coverage with 222+ passing tests

### Breaking Changes from GetX

- **Removed GetConnect module** - HTTP/WebSocket communication module has been removed
- **Removed mini stream** - Stream-related utilities have been removed
- **Removed all deprecated methods** - Cleaned up all deprecated APIs from the original GetX

## Installation

Add GetXify to your pubspec.yaml file:

```yaml
dependencies:
  getxify:
```

Import getxify in files that it will be used:

```dart
import 'package:getxify/getxify.dart';
```

## Quick Start

Replace `import 'package:get/get.dart';` with `import 'package:getxify/getxify.dart';`

The API is fully compatible with GetX. All your existing GetX code will work with GetXify.

### Basic Example

```dart
void main() => runApp(GetMaterialApp(home: Home()));

class Controller extends GetxController {
  var count = 0.obs;
  increment() => count++;
}

class Home extends StatelessWidget {
  final Controller c = Get.put(Controller());

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),
      body: Center(child: ElevatedButton(
        child: Text("Go to Other"),
        onPressed: () => Get.to(Other())
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: c.increment
      ),
    );
  }
}

class Other extends StatelessWidget {
  final Controller c = Get.find();
  @override
  Widget build(context) {
    return Scaffold(body: Center(child: Text("${c.count}")));
  }
}
```

## Documentation

For detailed documentation on all features, please refer to the official [GetX documentation](https://github.com/jonataslaw/getx).

GetXify maintains the same API and features as GetX, so all GetX documentation applies directly to GetXify.

### Key Features

- **State Management** - Reactive and simple state managers
- **Route Management** - Navigation without context
- **Dependency Management** - Smart dependency injection
- **Internationalization** - Easy translations and locales
- **Theme Management** - Simple theme switching
- **Utils & Helpers** - Platform detection, responsive design, and more

## Migration from GetX

If you were using GetX and want to migrate to GetXify:

- Replace `import 'package:get/get.dart';` with `import 'package:getxify/getxify.dart';`
- Replace `get` dependency with `getxify` in pubspec.yaml
- If you were using GetConnect, you'll need to implement your own HTTP client using dio or http package
- If you were using mini stream utilities, migrate to standard Dart streams or RxDart
- All deprecated methods have been removed, so update your code to use the current APIs

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

GetXify is released under the MIT License. See the [LICENSE](LICENSE) file for details.
