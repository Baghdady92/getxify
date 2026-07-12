## Unreleased

### Upstream Sync

- **Merged upstream getxify 3.0.0** - Adopted the restructured `lib/get_navigation/src/routes/` layout (`core/`, `router/`, `transitions/` subdirectories) and the naming cleanups (`_singletons`, `GetInstanceExt`, `RxTNew`); all of this fork's fixes are preserved on top. Upstream 3.0.0's functional changes were already present in 4.0.0.

### Bug Fixes

- **`assign`/`assignAll` no longer require a growable backing collection** - `RxList`/`RxSet`/`RxMap` created from fixed-length or unmodifiable sources (e.g. `List.empty().obs`, `const [].obs`, `Set.unmodifiable(...).obs`) previously crashed with "Cannot clear a fixed-length list" when assigned; the backing collection is now replaced with a fresh mutable copy (preserving its runtime element type), listeners are notified exactly once, and the collection is fully mutable afterwards. `Map.assignAll` also no longer emits a redundant second notification.

### Upstream Issue Fixes — Round 4

A final sweep over the remaining screened backlog candidates fixed 34 more issues (all with regression tests), including the last deferred structural item:

#### Nested Navigation (structural)

- **iOS swipe-back works between sibling routes inside `GetRouterOutlet`** - Outlets now stack the sibling pages of every history entry sharing their anchor (previous siblings stay mounted, retaining state), and imperative pops on the outlet navigator (back-swipe gesture, `Navigator.pop`, AppBar back) are reflected into the navigation history (getx#2107)
- **Fixed 'Multiple widgets used the same GlobalKey' with duplicate same-anchor outlets** - The shared nested-delegate key attaches only to the most recently mounted outlet (getx#2742)
- **Async `redirectDelegate` results are honored for an outlet's `initialRoute`** - Resolved post-frame with change detection so stable decisions cannot rebuild in a loop (getx#1978)

#### Navigation & Routing

- **The iOS back-swipe now starts only near the leading edge by default** - matching native iOS, so it no longer hijacks sliders/carousels; `popGesture: true` keeps the historical full-screen area and `gestureWidth: (_) => double.infinity` restores it explicitly (getx#3209)
- **Fixed `offAllNamed` to the surviving bottom route keeping stale content** - The page is rebuilt and its bindings/controllers recreated (getx#2899)
- **Fixed the initial Flutter Web URL report pushing an extra history entry** - which activated the browser back button on a plain page load (getx#3266)
- **`GetMaterialApp` renders its initial route on the first pump in widget tests** - like GetX 4; no extra `pumpAndSettle` needed (getx#3244)
- **Fixed tear-off route names** - `Get.to(MyPage.new)` no longer generates names polluted with the parameter list (getx#2245)
- **Fixed `Get.rawRoute` becoming null after `Get.offAllNamed`** (getx#1237)
- **`Get.back` returns `bool`** - so callers can detect an ignored back navigation (getx#2474)
- **Descriptive `GetPage` name assert** - states the offending name and the leading-slash requirement (getx#2564)
- **`Transition.downToUp` no longer reveals a black background** - the outgoing page stays in place, modal-style (getx#1560)
- **`Transition.circularReveal` radius is computed from the screen size** - fixing clipped corners on iPad Pro 12.9 (getx#3130)
- **Added `Transition.predictiveBack`** - per-route Android predictive back without configuring `pageTransitionsTheme` (getx#3109)
- **`transitionDuration` on `GetMaterialApp`/`GetCupertinoApp` is honored** - previously dead config (getx#2503)
- **Added `customTransition` to `Get.to`/`Get.off`/`Get.offAll`** - imperative navigation can use `CustomTransition` animations (getx#2475)
- **Added `GetPage.allowSnapshotting`** - disable route-transition snapshotting per page (getx#3282)

#### Dialogs, Sheets & Snackbars

- **Overlays own their arguments and dependencies correctly** - `Get.arguments` returns the overlay's arguments while it is topmost (getx#2122); `Get.bottomSheet` gains `arguments`/`name` (getx#2005); controllers `Get.put` while an overlay is open belong to the page beneath and survive the overlay's dismissal (getx#1969)
- **Added `canPop` to `Get.defaultDialog`** - block back-gesture dismissal (getx#3184)
- **Added `transitionBuilder` to `Get.dialog`** - custom dialog animations without `Get.generalDialog` (getx#3127)
- **Snackbar queue robustness** - closing a still-queued snackbar no longer crashes (getx#2761) or mounts broken overlay state later (getx#2257); `closeCurrentSnackbar`/`cancelAllSnackbars` (and the `Get.` wrappers) gain `withAnimations` (getx#2400)
- **Snackbar rendering** - RTL icon paddings mirror correctly (getx#3069) and the left bar indicator respects `borderRadius` (getx#2747)

#### State Management, Rx & i18n

- **`GetBuilder`/`Bind` rebinds when its `tag` changes on rebuild** - disposing an autoRemove controller created under the old tag (getx#2232)
- **Descriptive `BindError` on (type, tag) mismatch** - instead of an opaque null-check crash (getx#2573)
- **Controllers created inside native `showModalBottomSheet`/`showDialog` builders no longer leak** (getx#2439)
- **Fixed `RxSet.assign`/`assignAll` notifying twice** - one event with the final contents (getx#2250)
- **Added `autoPlayOnUpdate` to `GetAnimatedBuilder` and all animation extensions** - declarative replays driven by Obx state (getx#2760)
- **CLDR plural-category support** - `PluralCase`, pluggable `Get.pluralResolver`, and `trPluralCases`/`trPluralCasesParams` for languages like Arabic and Russian (getx#1855)
- **Added `restorationScopeId` to `GetMaterialApp`/`GetCupertinoApp`** - enabling app-level state restoration (getx#2144)

---

## 4.0.0

### Code Quality Improvements

- **Fixed parameter naming in RxList** - Corrected parameter names in `fillRange` and `replaceRange` methods to match the overridden method signatures from Dart's List interface (changed `fillValue` to `fill` and `replacement` to `newContents`)

- **Enhanced RxSet factory constructors** - Added missing factory constructors (`from`, `of`, `unmodifiable`, `identity`) to match Dart's Set API and provide complete factory constructor coverage

- **Enhanced RxMap factory constructors** - Added missing factory constructors (`fromIterable`, `fromIterables`, `fromEntries`) to match Dart's Map API and provide complete factory constructor coverage

- **Fixed null safety in RxnString** - Removed `Comparable<String>` and `Pattern` interfaces from `RxnString` class as they don't make sense for nullable String types and were using forced null unwrap which could cause runtime exceptions

- **Maintained backward compatibility** - Kept both `.obs` extension methods (getter-style and method-style) to ensure compatibility with existing code while supporting Dart 3 features

- **Cleaned up navigation extensions** - Removed unrelated UI, layout, and media query properties (such as `pixelRatio`, `width`, `height`, `statusBarHeight`, `bottomBarHeight`, `textScaleFactor`, `textTheme`, `mediaQuery`, `isDarkMode`, `isPlatformDarkMode`, `iconColor`, `focusScope`) from `extension_navigation.dart` to keep the navigation module focused solely on routing and state features.

### Bug Fixes

- **Fixed parameter name mismatch warnings** - Resolved analyzer warnings about parameter names not matching overridden method signatures in RxList

- **Fixed overlay closure logic** - Fixed a logical bug in `closeAllDialogsAndBottomSheets` where it incorrectly required *both* a dialog and a bottom sheet to be open simultaneously to close them (changed the condition check from `&&` to `||`).

### Upstream Issue Fixes

Fixes for 24 bugs reported on the upstream GetX issue tracker (jonataslaw/getx) that were confirmed to exist in this codebase, each covered by new regression tests.

#### Navigation & Routing

- **Fixed frozen previous-page animation during route transitions** - `GetPageRouteTransitionMixin.canTransitionTo` now accepts `MaterialRouteTransitionMixin` routes (mirroring Flutter's own implementation), so the outgoing page animates when a plain `MaterialPageRoute` is pushed over a `GetPageRoute` under `GetMaterialApp` (getx#3452)
- **Fixed back navigation over imperatively pushed routes** - `Get.back()`, the system back button/gesture, and the iOS edge-swipe now pop pageless routes (e.g. `OpenContainer`, raw `Navigator.push`) through the Navigator instead of removing the underlying page from the router delegate's history, which previously tore down two screens at once (getx#3436)
- **Fixed browser history on Flutter Web** - Replace-style navigations (`Get.off`, `Get.offAll`, `Get.offAllNamed`, etc.) are now reported to the browser as history replacements via the new default `GetRouteInformationProvider`, and browser back/forward to a route already on the stack pops back to it instead of resurrecting removed pages (getx#3372)
- **Fixed `Get.closeOverlay()` popping page routes like `Get.back()`** - It now closes the actual overlay when called right after an awaited navigation, and the router history no longer removes the wrong route (getx#3316)
- **Fixed `Get.close()` dropping its `result` and `id` arguments** - Awaited `Get.bottomSheet`/`Get.dialog` futures now complete with the provided result (getx#3319, getx#3387)
- **`Get.close`, `Get.closeDialog` and `Get.closeBottomSheet` now close native overlays** - Dialogs and sheets opened with Flutter's own `showDialog`/`showModalBottomSheet` are recognized by inspecting the navigator's top route instead of relying solely on GetX routing flags (getx#3342)
- **Overlay status getters no longer throw before routing is initialized** - `Get.isOverlaysOpen`, `Get.isDialogOpen`, `Get.isBottomSheetOpen` and `Get.isSnackbarOpen` return `false`/`null` instead of throwing "GetRoot is not part of the tree" (getx#3370)
- **Made `SnackbarController.close()` idempotent** - Closing an already-dismissed snackbar no longer asserts "Cannot remove entry from a disposed snackbar", and `close(withAnimations: false)` cancels the pending duration timer (getx#3343)
- **Fixed `unknownRoute` never being shown when a root `/` page is registered** - `ParseRouteTree.matchRoute` no longer treats a partial ancestor match as a full match (getx#3352)
- **Fixed null-check crash in `PageRedirect.getPageToRoute`** - Navigating to an unmatched route with no `unknownRoute` configured now degrades gracefully to the delegate's not-found page instead of crashing (getx#3367)
- **Middleware redirects can forward navigation arguments** - `RouteDecoder.fromRoute` accepts an optional `arguments` parameter so `redirectDelegate` targets can access the original `Get.arguments` (getx#3408)
- **Fixed `Get.previousRoute` corruption after pops** - `GetObserver.didPop` no longer sets `Routing.previous` equal to `Routing.current`, which also broke the `preventDuplicates` check in `Get.off` (getx#3394)
- **Fixed `Get.key` throwing "GetRoot is not part of the tree" before the app mounts** - `GetMaterialApp(navigatorKey: Get.key)` now works (getx#3323)
- **Fixed theme changes being ignored when `GetMaterialApp` is rebuilt by a parent** - `GetRootState` now reconciles updated `ConfigData` (theme, darkTheme, themeMode, locale, ...) in `didUpdateWidget`, so wrapping `GetMaterialApp` in `Obx` works (getx#3371)
- **Fixed device-locale changes overriding an explicitly set app locale** - `didChangeLocales` only follows the device locale when the app never set one via `GetMaterialApp(locale:)` or `Get.updateLocale` (getx#3357)
- **Added `scrollable` parameter to `Get.defaultDialog`** - Forwarded to `AlertDialog.scrollable` to prevent overflow with tall content (getx#3330)

#### Dependency Injection & Lifecycle

- **Fixed deferred route disposal destroying freshly created controllers** - When a route is popped and the same controller is re-registered before the old route finishes disposing (rapid back-and-forth navigation, re-push during exit transition, or `Get.offAllNamed` to a route reusing the same controller type), only the superseded instance is disposed; the live controller stays registered and its `onInit` lifecycle is preserved (getx#3446, getx#3315, getx#3351)
- **Fixed stale dirty flag on `fenix` registrations** - A `fenix` factory retained after deletion is no longer perpetually treated as stale, fixing missed `onClose` calls on resurrected controllers (getx#3292)
- **Fixed controllers being linked to the wrong route** - When multiple pages are pushed within the same frame, each route's bindings and lazily-created controllers now link to their own route instead of the topmost one, so popping the top route no longer disposes them all (getx#3280)

#### Reactive Types

- **Fixed default-constructed `RxList`/`RxSet`/`RxMap` being unusable** - The default constructors previously backed the collection with an immutable `Never`-typed const literal, so the first `add()`/`[]=` threw a `TypeError`; they now create properly typed growable collections (getx#3411)

#### Internationalization

- **Fixed translation lookup ignoring `Locale.scriptCode`** - `tr` now resolves keys in specificity order (`lang_script_country` > `lang_script` > `lang_country` > `lang` > similar-language) for both `Get.locale` and `Get.fallbackLocale`, so `Locale('zh', scriptCode: 'Hant')` no longer resolves to `zh_CN` (getx#3380)

#### Review Hardening

Follow-up fixes found by an adversarial review of the changes above:

- **Fixed browser back desync with duplicate same-name history entries** - A platform back reporting the current top route's name now pops to the lower duplicate instead of leaving the app stack out of sync with the browser history
- **Fixed same-frame replace/push misreporting** - An ordinary `to`/`toNamed` push issued synchronously after a replace-style navigation in the same frame is now reported to the browser as a push instead of inheriting the replace semantics
- **Fixed superseded `GetxService` leaking in the `lateRemove` chain** - A stale, already-replaced service now receives `onClose`/`onDelete` on a non-force delete and no longer makes the live registration permanently undeletable; the service-protection guard still applies to live instances
- **`Get.updateLocale` now records explicit locale intent** - An OS locale change can no longer override a user-selected locale that happens to equal the previously auto-applied device locale

### Upstream Issue Fixes — Round 2

A second sweep over the full upstream backlog (~960 additional issues screened, ~110 deep-triaged) fixed 50 more confirmed defects, each with new regression tests.

#### System Back & Pop Behavior

- **System back / predictive back now respects `PopScope`, `WillPopScope` and `GetPage.canPop`** - `GetDelegate.popRoute` consults the route's pop disposition like `NavigatorState.maybePop`, and a blocked pop reports `onPopInvoked` with `didPop: false` (getx#3216, getx#2996, getx#2704, getx#2869, getx#2434, getx#2188)
- **Browser back on Flutter Web respects pop vetoes** - Single-page back navigations consult `PopScope`/`WillPopScope`/`canPop` before popping (getx#3121)
- **Browser back with an open dialog/bottom sheet now closes the overlay** - instead of popping the underlying page (getx#3322)
- **`Get.back()`/`Get.close()` now close open Scaffold drawers** - and other local-history entries such as persistent bottom sheets, without popping the page (getx#3227, getx#2717)

#### Navigation & Routing

- **Fixed `preventDuplicates` being ignored in Navigator 2.0** - `GetPage.copyWith` no longer drops `preventDuplicateHandlingMode`, `preventDuplicates: false` on `Get.to`/`Get.toNamed`/`GetPage` pushes duplicates again, and `popUntilOriginalRoute` pops back to (not past) the original route (getx#3261, getx#3251, getx#2975, getx#3054)
- **`Get.arguments`/`Get.parameters` are scoped to the building page** - pages pushed in the same action no longer see each other's arguments (getx#2286)
- **Fixed `Get.to` with different closures returning the same widget type** - navigation no longer silently re-shows the old page (getx#2161)
- **`initialRoute` is honored when a `/` page is registered** - the app starts on `initialRoute` and `/` stays reachable (getx#3196)
- **A stopped initial route no longer leaves a blank screen** - the delegate falls back to the not-found page when middleware nullifies the first navigation or a deep link (getx#2949)
- **Fixed `Get.currentRoute`/`Get.previousRoute` corruption by overlays** - dismissing stacked dialogs/sheets no longer leaves synthetic `DIALOG/BOTTOMSHEET <hash>` names in routing state (getx#2597, getx#2334)
- **Web URL strategy is applied once per process** - no more "Cannot set URL strategy a second time" crashes (getx#3224)
- **`Get.defaultDialog` renders its custom action** - `custom`, `textCustom` and `onCustom` were previously silently ignored (getx#1716, getx#3042, getx#1381)
- **`Get.showOverlay` always cleans up on error** - including non-`Exception` throws like Strings and Errors (getx#2827)
- **`Get.bottomSheet` works inside `GetCupertinoApp`** - falls back to `DefaultMaterialLocalizations` when no material delegates are installed (getx#2337)
- **`shortcuts` parameter type matches `MaterialApp`** - now `Map<ShortcutActivator, Intent>?`, accepting `SingleActivator`/`CharacterActivator` (getx#2615)
- **Snackbar no longer blocks taps around it** - the margin and the space beside width-constrained snackbars pass pointer events through, while the bar stays tappable and swipe-dismissible (getx#3012, getx#2995)

#### Middleware & Route Tree

- **v4-style `GetMiddleware.redirect()` is honored again** - in all named navigation, with forwarded arguments; replace-style navigations (`off`/`offAll`/`offAllNamed`) now run middleware, so `redirectDelegate` returning null stops them too (getx#2779, getx#2713, getx#2579, getx#2231)
- **Middlewares run in `priority` order and stop at the first redirect** (getx#1298)
- **Middleware lifecycle callbacks run once, on the declaring page's route** - instead of once per page in the nested stack; nested flattening no longer registers duplicate routes; navigation guards remain inherited by children (getx#3170)
- **`Get.parameters` reflects the in-flight route while middlewares run** - including parameters added by a redirect; redirect cycles degrade to the not-found page instead of freezing (getx#3139)
- **`onPageCalled` returning null cancels the page gracefully** - instead of a null-check crash (getx#2909)
- **A parent `GetPage`'s `binding` runs when the initial route is a child page** - inherited bindings execute parents-first (getx#2085)
- **`GetRouterOutlet.initialRoute` runs the middleware pipeline** - synchronous `redirect`/`redirectDelegate` results are honored (async initial-route guards remain a documented limitation) (getx#1978)

#### Nested Navigation & GetRouterOutlet

- **Nested shells stay mounted when unrelated root routes sit on top** - `participatesInRootNavigator` shells (with their navigators and controllers) survive sibling navigation, and pops restore the previously selected nested child (getx#3336, getx#2011)
- **Doubly nested `GetRouterOutlet`s work** - deeper outlets' pages no longer leak into the outer navigator, and outlets no longer fail the Navigator pages-API assertion (getx#3347, getx#2638)
- **Pages marked `participatesInRootNavigator` are no longer mounted twice** (getx#3111)
- **Anchorless `GetRouterOutlet` no longer reuses the root navigator's `GlobalKey`** - fixing a guaranteed duplicate-key failure (getx#2742)
- **Hero animations fly exactly once** - removed `GetNavigator`'s duplicate `HeroController` (the framework scope owns it), gave nested outlets their own persistent `HeroControllerScope`, and back-gesture detectors disposed mid-drag no longer leave the navigator stuck in `userGestureInProgress` (getx#3350, getx#2931)

#### Transitions & Gestures

- **`Transition.native` honors the theme's `pageTransitionsTheme`** - e.g. `PredictiveBackPageTransitionsBuilder` (getx#2340)
- **`Get.defaultTransition` is no longer force-initialized from the fallback theme** - routes without an explicit transition follow the app theme on all platforms (getx#3274)
- **`gestureWidth` takes effect** - when set, the back-swipe only starts within that width from the leading edge (getx#3373)
- **Back-swipe direction fixed for `Transition.leftToRight`/`leftToRightWithFade`** - the page follows the finger toward the edge it entered from (getx#2193)

#### Dependency Injection & State Management

- **Restored `Get.putAsync` and added `Bind.putAsync`** - asynchronously-constructed dependencies register through `put()` with the full lifecycle (getx#3239)
- **`Get.reloadAll()` calls `onDelete`/`onClose` before clearing instances** - and skips `GetxService`s unless forced, matching `Get.reload<S>()` (getx#2397)
- **Nullable generic registrations share the non-nullable registry key** - `Get.put<App?>(...)` is visible to `Get.find<App>()` (getx#2657)
- **`Get.replace`/`Get.lazyReplace` (and the `Bind` variants) really replace** - fenix registrations, `GetxService`s and pending `lateRemove` chains no longer resurrect the old builder (getx#2268)
- **`GetBuilder(global: false)` controllers receive `onClose` on unmount** - unless `autoRemove: false` (getx#2123)
- **Controllers survive tree-shape swaps** - a `LayoutBuilder` breakpoint change no longer deletes the controller the visible page is using; disposal defers to the last live subscriber (getx#2393)
- **`GetBuilder`/`Bind` `initState` callbacks can access `state.controller`** - the callback now runs after the controller is available (getx#2354)
- **Ticker providers follow `TickerMode`** - `GetSingleTickerProviderStateMixin`/`GetTickerProviderStateMixin` tickers are muted when the route is covered (getx#2426)
- **Renamed `rx_ticket_provider_mixin.dart` to `rx_ticker_provider_mixin.dart`** - fixing the long-standing typo (getx#2801)

#### Reactive Types, Utils & Animations

- **`bindStream` no longer leaks subscriptions** - it returns its `StreamSubscription`, supports `cancelPrevious: true`, and cancels all bindings when the Rx closes (getx#3000)
- **`GetPlatform.isMacOS` works on Firefox for macOS** - and iPad/iPod `navigator.platform` values are detected correctly (getx#1936)
- **`BlurAnimation` blurs its child, not the backdrop** - and `GetAnimatedBuilder` honors updated `duration`/`tween`/`curve` on rebuild (getx#3233)
- **Documented `trParams` placeholder ordering for RTL translations** - with regression tests (getx#3073)

#### Review Hardening — Round 2

Follow-up fixes from an adversarial review of this round's changes:

- **Fixed `Get.reloadAll()` throwing `ConcurrentModificationError`** - when an instance's `onClose` mutates the registry
- **Middleware redirect cycles can no longer hang navigation** - the delegate detects revisited locations and settles on the not-found route
- **Platform-back no longer pops the wrong pages** - when a `willPop` callback navigates during the veto check, the target entry is re-located by identity after the await
- **Fixed `GetAnimatedBuilder` leaking `CurvedAnimation` objects** - they are now owned and disposed across updates and unmount
- **Hardened in-flight middleware parameters against overlapping navigations** - `resolvingParameters` uses save/restore semantics instead of clear-to-null

### Upstream Issue Fixes — Round 3 (structural)

Three long-standing structural defects that earlier rounds deferred, plus internal cleanups:

- **Pops through the router delegate now play the pop animation** - When a pop surfaces to a navigator as a page replacement (the norm inside `GetRouterOutlet`), the new pop-aware `GetTransitionDelegate` (default for the root and outlet navigators; a user-supplied `transitionDelegate` still wins) animates the leaving route in reverse on top of the revealed page instead of playing a forward push animation; a `PopMode.page` pop of the only history entry now replaces it with the parent branch instead of pushing the parent on top of the leaf (getx#1883)
- **Deep links no longer take ownership of ancestor pages' controllers** - Dependencies registered by bindings inherited from ancestor pages are linked to the declaring ancestor's route, so leaving a deep-linked leaf no longer disposes controllers the still-visible parent view depends on (getx#2183)
- **Route disposal no longer deletes controllers a still-visible view depends on** - Deletion of a route-linked instance that still has widget subscribers is deferred to end-of-frame; if subscribers remain after the disposed route's subtree unmounted, the instance is kept alive for the views that use it (getx#2404)
- **Internal cleanups** - Shared `GetTickerProvider` interface unifies TickerMode forwarding across `GetBuilder`/`Bind`/`GetX`; the bottom-sheet MaterialLocalizations fallback moved into `GetModalBottomSheetRoute.buildPage` (also fixing direct route users under Cupertino apps); overlay close loops resolve the navigator's top route once per iteration and `Get.close()` evaluates its predicates lazily; centralized routing-initialization guards; removed dead code

Known remaining limitation: the iOS swipe-back gesture still cannot pop between sibling routes inside a `GetRouterOutlet` (getx#2107) — it requires cumulative history-derived outlet stacks, a state-retention semantics change documented for future work.

---

## 3.0.0

_Upstream (Aniketkhote/getxify) release, merged into this fork after 4.0.0._

### Code Quality Improvements

- **Restructured navigation routes** - Reorganized the flat `lib/get_navigation/src/routes/` directory into three structured subdirectories (`transitions/`, `router/`, and `core/`) to improve codebase organization and readability.
- **Refactored naming conventions** - Renamed the legacy truncated private map `_singl` to `_singletons` and the `Inst` extension to `GetInstanceExt` in `extension_instance.dart`. Renamed the `RxTnew` extension to `RxTNew` in `rx_impl.dart` to adhere to Dart's UpperCamelCase style guidelines.
- Also included code-quality and bug fixes that shipped independently in this fork's 4.0.0 (RxList parameter naming, RxSet/RxMap factory constructors, RxnString null safety, navigation-extension cleanup, and the `closeAllDialogsAndBottomSheets` condition fix).

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
