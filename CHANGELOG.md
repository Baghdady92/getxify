## 3.0.0

### Code Quality Improvements

- **Restructured navigation routes** - Reorganized the flat `lib/get_navigation/src/routes/` directory into three structured subdirectories (`transitions/`, `router/`, and `core/`) to improve codebase organization and readability.

- **Refactored naming conventions** - Renamed the legacy truncated private map `_singl` to `_singletons` and the `Inst` extension to `GetInstanceExt` in `extension_instance.dart`. Renamed the `RxTnew` extension to `RxTNew` in `rx_impl.dart` to adhere to Dart's UpperCamelCase style guidelines.

- **Fixed parameter naming in RxList** - Corrected parameter names in `fillRange` and `replaceRange` methods to match the overridden method signatures from Dart's List interface (changed `fillValue` to `fill` and `replacement` to `newContents`)

- **Enhanced RxSet factory constructors** - Added missing factory constructors (`from`, `of`, `unmodifiable`, `identity`) to match Dart's Set API and provide complete factory constructor coverage

- **Enhanced RxMap factory constructors** - Added missing factory constructors (`fromIterable`, `fromIterables`, `fromEntries`) to match Dart's Map API and provide complete factory constructor coverage

- **Fixed null safety in RxnString** - Removed `Comparable<String>` and `Pattern` interfaces from `RxnString` class as they don't make sense for nullable String types and were using forced null unwrap which could cause runtime exceptions

- **Maintained backward compatibility** - Kept both `.obs` extension methods (getter-style and method-style) to ensure compatibility with existing code while supporting Dart 3 features

- **Cleaned up navigation extensions** - Removed unrelated UI, layout, and media query properties (such as `pixelRatio`, `width`, `height`, `statusBarHeight`, `bottomBarHeight`, `textScaleFactor`, `textTheme`, `mediaQuery`, `isDarkMode`, `isPlatformDarkMode`, `iconColor`, `focusScope`) from `extension_navigation.dart` to keep the navigation module focused solely on routing and state features.

### Bug Fixes

- **Fixed parameter name mismatch warnings** - Resolved analyzer warnings about parameter names not matching overridden method signatures in RxList

- **Fixed overlay closure logic** - Fixed a logical bug in `closeAllDialogsAndBottomSheets` where it incorrectly required *both* a dialog and a bottom sheet to be open simultaneously to close them (changed the condition check from `&&` to `||`).

---

## 2.0.2

### Refactoring & Code Quality

- **Cleaned up `get_rx` bloat** - Removed over 1,000 lines of redundant, unrelated proxy helper methods from `RxNum`, `RxInt`, `RxDouble`, and `RxString` extensions, aligning the reactive wrappers with the core project scope. Core basic mathematical, relational, and bitwise operators were retained.
- **Enhanced Documentation** - Added comprehensive Dart documentation comments and examples to public classes, extensions, methods, and callbacks across `get_instance`, `get_core`, `get_animations`, `get_common`, and `get_rx` modules.
- **Removed comment/code boilerplate** - Cleaned up commented-out methods, legacy variables, and dead code references across the entire codebase.

### Performance Optimizations

- **Optimized `RxList`, `RxMap`, and `RxSet`** - Overrode batch-mutating collection methods (such as `clear()`, `removeAt()`, `addAll()`, `removeWhere()`, etc.) to directly mutate the underlying standard Dart collections and trigger exactly one reactive refresh notification. This prevents multiple redundant widget rebuild cycles.

### Bug Fixes

- **Corrected doc comment typos** - Fixed possessive "it's" typos, brackets in generics `[find]<[S]>()`, and incorrect method references (`Get.[create]`) in documentation.

---

## 2.0.1

### Bug Fixes

- **Fixed RxnDouble subtraction operator** - The subtraction operator in `RxnDoubleExt` was incorrectly using addition instead of subtraction, now properly subtracts the given value.
- **Fixed ListExtension assign methods** - Added `clear()` call for non-RxList cases in both `assign()` and `assignAll()` methods to ensure proper list clearing before adding new items.
- **Fixed null safety in navigation extensions** - Replaced unsafe null assertion operators (`!`) with null-aware operators (`?? false`) for `isDialogOpen` and `isBottomSheetOpen` checks in `extension_navigation.dart` to prevent null pointer exceptions.
- **Fixed GetPage copyWith restorationId** - Fixed bug where `restorationId` parameter was being compared with itself instead of `this.restorationId` in the `copyWith` method.
- **Fixed ColorAnimation color filter** - Simplified ColorAnimation to use the animated value directly instead of incorrectly interpolating with Color.lerp, which was causing incorrect color filtering behavior.
- **Fixed dependency deletion logic** - Improved dependency cleanup in `extension_instance.dart` with recursive factory cleanup for `lateRemove` dependencies and proper fenix mode handling.
- **Fixed isDesktop context extension** - Fixed `isDesktop` getter to correctly reference `isDesktopOrWider` instead of `isDesktopOrLess`, ensuring proper desktop breakpoint detection.

---

## 2.0.0

### Breaking Changes

- **Removed GetUtils class** - The `GetUtils` class with 722 lines of validation and string manipulation methods has been removed. This includes:
  - Validation methods: `isEmail`, `isURL`, `isPhoneNumber`, `isDateTime`, `isMD5`, `isSHA1`, `isSHA256`, `isSSN`, `isBinary`, `isIPv4`, `isIPv6`, `isHexadecimal`, `isPalindrome`, `isUsername`, `isCurrency`, `isPassport`, Brazilian `isCpf`/`isCnpj`
  - File type checks: `isVideo`, `isImage`, `isAudio`, `isPPT`, `isWord`, `isExcel`, `isAPK`, `isPDF`, `isTxt`, `isChm`, `isVector`, `isHTML`
  - String manipulation: `capitalize`, `capitalizeFirst`, `removeAllWhitespace`, `camelCase`, `snakeCase`, `paramCase`, `numericOnly`, `capitalizeAllWordsFirstLetter`
  - Length validation methods
  - Basic type checks: `isNull`, `isNullOrBlank`, `isBlank`, `isNum`, `isNumericOnly`, `isAlphabetOnly`, `hasCapitalLetter`, `isBool`

- **Removed string extensions** - All string extensions that wrapped GetUtils methods have been removed:
  - `isNum`, `isNumericOnly`, `isAlphabetOnly`, `isBool`
  - `isVectorFileName`, `isImageFileName`, `isAudioFileName`, `isVideoFileName`, `isTxtFileName`, `isDocumentFileName`, `isExcelFileName`, `isPPTFileName`, `isAPKFileName`, `isPDFFileName`, `isHTMLFileName`
  - `isURL`, `isEmail`, `isPhoneNumber`, `isDateTime`
  - `capitalize`, `capitalizeFirst`, `removeAllWhitespace`, `camelCase`, `paramCase`, `numericOnly`, `capitalizeAllWordsFirstLetter`

- **Removed unused extensions** - The following extension modules have been removed:
  - `double_extensions.dart`
  - `duration_extensions.dart`
  - `dynamic_extensions.dart`
  - `int_extensions.dart`
  - `num_extensions.dart`
  - `widget_extensions.dart`

- **Removed GetMicrotask class** - The `GetMicrotask` class has been removed as it was not used anywhere in the codebase.

- **Removed OptimizedListView widget** - The `OptimizedListView` widget has been removed as it was not used anywhere in the codebase.

### Migration Guide

If you were using any of the removed utilities, you should migrate to dedicated packages:

- **Validation**: Use the [`validator`](https://pub.dev/packages/validator) package or similar
- **String manipulation**: Use the [`recase`](https://pub.dev/packages/recase) package for case conversion
- **File operations**: Use the [`path`](https://pub.dev/packages/path) package
- **Equality**: Use the [`equatable`](https://pub.dev/packages/equatable) package if you need value-based equality in your own code

### Bug Fixes

- **Fixed controller disposal during rapid navigation** - Controllers are now properly disposed when quickly navigating back and forth using keyboard shortcuts or programmatic navigation. Added `reportRouteWillDispose` call in the `didPop` method of `GetObserver` to ensure dependencies are cleaned up correctly.
- **Fixed secondary animation issue** - Outgoing pages now animate correctly when using `Navigator.push` with `GetMaterialApp` or `GetCupertinoApp`. The apps now use regular `MaterialApp`/`CupertinoApp` when `getPages` is null and no router config is provided, allowing proper secondary animations for imperative navigation.
- **Fixed null routerDelegate handling** - `GetRoot` now properly handles cases where `routerDelegate` is null, preventing runtime errors when accessing navigation keys in non-router scenarios.

### Improvements

- **Reduced bundle size** - Removed ~1000+ lines of unnecessary utility code
- **Focused scope** - GetXify now focuses on its core purpose: state management, navigation, and dependency injection
- **Better separation of concerns** - General-purpose utilities should use dedicated packages, not a framework

### Kept Functionality

The following essential utilities remain:

- `Equality` mixin - Needed by `StateMixin` for value-based equality comparison
- `GetPlatform` - Platform detection (used in 3 places in core framework)
- `GetQueue` - Queue management (used by snackbar system)
- `IterableExtensions` - `mapMany`, `firstWhereOrNull` (used by router)
- `ContextExtensions` - `theme`, `mediaQuery`, `height`, `width` (used by responsive design and navigation)
- `InternationalizationExtensions` - `.tr` extension for translations
- `EventLoopExtensions` - `asap`, `toEnd` methods (used by core framework)
- `printInfo` method - Added to `GetInterface` for logging

### Testing

- All 144 tests passing

## 1.0.2

### Code Quality Improvements

- **Enhanced documentation** - Added comprehensive doc comments to get_state_manager module (list_notifier, rx_notifier, get_responsive, rx_getx_widget, mixin_builder, simple_builder)
- **Code cleanup** - Removed dead/commented code across get_state_manager files
- **Modernized patterns** - Updated constructor patterns to use `super.key` in doc examples
- **Removed outdated lint ignores** - Cleaned up unnecessary lint suppression comments
- **Fixed field overrides** - Properly fixed field override issue in \_FactoryBind using super parameters

### Testing

- All 222 tests passing

---

## 1.0.1

### Code Quality Improvements

- **Internal codebase improvements** - Enhanced code structure and organization
- **Removed dead code** - Cleaned up commented-out and unused code across multiple modules
- **Added safety checks** - Improved widget lifecycle checks to prevent errors
- **Enhanced API documentation** - Added comprehensive documentation comments for better developer experience

### Feature Updates

- **BottomSheet** - Added new parameters to align with latest Flutter API
- **Snackbar** - Added new parameters to align with latest Flutter API
- **Router configuration** - Improved initialization logic for better compatibility

### Testing

- **Expanded test coverage** - Added more tests to ensure stability
- All 222 tests passing

---

## 1.0.0

### Initial Release - GetXify

GetXify is an improved and enhanced version of GetX, compatible with the latest Dart and Flutter versions.

### Breaking Changes

- **Removed GetConnect module** - HTTP/WebSocket communication module has been removed
- **Removed mini stream** - Stream-related utilities have been removed
- **Removed all deprecated methods** - Cleaned up all deprecated APIs from the original GetX

### Improvements

- Updated to support Dart SDK ^3.12.2
- Updated to support Flutter >=3.44.2
- Code cleanup and modernization
- Removed legacy dependencies and unused code
- Improved performance and stability

### Migration from GetX

If you were using GetX and want to migrate to GetXify:

- Replace `import 'package:get/get.dart';` with `import 'package:getxify/getxify.dart';`
- Replace `get` dependency with `getxify` in pubspec.yaml
- If you were using GetConnect, you'll need to implement your own HTTP client using dio or http package
- If you were using mini stream utilities, migrate to standard Dart streams or RxDart
- All deprecated methods have been removed, so update your code to use the current APIs

### Features

GetXify maintains all the core features of GetX:

- State Management (Reactive and Simple)
- Route Management (Navigation without context)
- Dependency Management (Dependency injection)
- Internationalization (i18n)
- Theme Management
- Utils and Helpers
