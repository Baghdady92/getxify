import 'package:flutter/material.dart';

import '../../../getxify.dart';

class RouterOutlet<TDelegate extends RouterDelegate<T>, T extends Object>
    extends StatefulWidget {
  final TDelegate routerDelegate;
  final Widget Function(BuildContext context) builder;

  RouterOutlet.builder({super.key, TDelegate? delegate, required this.builder})
    : routerDelegate = delegate ?? Get.delegate<TDelegate, T>()!;

  RouterOutlet({
    Key? key,
    TDelegate? delegate,
    required Iterable<GetPage> Function(T currentNavStack) pickPages,
    required Widget Function(
      BuildContext context,
      TDelegate,
      Iterable<GetPage>? page,
    )
    pageBuilder,
  }) : this.builder(
         builder: (context) {
           final currentConfig = context.delegate.currentConfiguration as T?;
           final rDelegate = context.delegate as TDelegate;
           var picked = currentConfig == null ? null : pickPages(currentConfig);
           if (picked?.isEmpty ?? true) {
             picked = null;
           }
           return pageBuilder(context, rDelegate, picked);
         },
         delegate: delegate,
         key: key,
       );
  @override
  RouterOutletState<TDelegate, T> createState() =>
      RouterOutletState<TDelegate, T>();
}

class RouterOutletState<TDelegate extends RouterDelegate<T>, T extends Object>
    extends State<RouterOutlet<TDelegate, T>> {
  RouterDelegate? delegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  void _listener() {
    setState(() {});
  }

  VoidCallback? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();
    final router = Router.of(context);
    delegate ??= router.routerDelegate;
    delegate?.addListener(_listener);
    disposer = () => delegate?.removeListener(_listener);

    _backButtonDispatcher = router.backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  void dispose() {
    super.dispose();
    disposer?.call();
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();
    return widget.builder(context);
  }
}

class GetRouterOutlet extends RouterOutlet<GetDelegate, RouteDecoder> {
  /// Creates a nested navigator that renders the tree-branch pages below
  /// [anchorRoute].
  ///
  /// The pages are taken from the deepest navigation history entry whose
  /// branch contains the anchor (so the outlet keeps its current child
  /// while an unrelated route is on top of the history), truncated after
  /// the first page that itself anchors a deeper outlet (its descendants
  /// are hosted by that outlet) and excluding pages marked with
  /// [GetPage.participatesInRootNavigator], which the root navigator
  /// renders. [filterPages] runs last and can further reduce the picked
  /// pages.
  ///
  /// When the picked set is empty the page matching [initialRoute] is
  /// rendered instead, resolved through the synchronous middleware surface
  /// ([GetMiddleware.redirect] and synchronous
  /// [GetMiddleware.redirectDelegate] results).
  GetRouterOutlet({
    Key? key,
    String? anchorRoute,
    required String initialRoute,
    Iterable<GetPage> Function(Iterable<GetPage> afterAnchor)? filterPages,
    GetDelegate? delegate,
    String? restorationScopeId,
  }) : this.pickPages(
         restorationScopeId: restorationScopeId,
         pickPages: (config) {
           Iterable<GetPage<dynamic>> ret;
           if (anchorRoute == null) {
             // jump the ancestor path
             final length = Uri.parse(initialRoute).pathSegments.length;

             ret = config.currentTreeBranch.skip(length).take(length);
           } else {
             final branch = _anchorBranch(
               config,
               anchorRoute,
               delegate ?? Get.rootController.rootDelegate,
             );
             ret = _stopAfterNestedOutletAnchor(
               branch.pickAfterRoute(anchorRoute),
               anchorRoute,
             );
           }
           // Pages participating in the root navigator are rendered by
           // [GetDelegate.build]; rendering them here as well would mount
           // them twice.
           ret = ret.takeWhile(
             (page) => page.participatesInRootNavigator != true,
           );
           if (filterPages != null) {
             ret = filterPages(ret);
           }
           return ret;
         },
         key: key,
         emptyPage: (delegate) =>
             _resolveInitialPage(delegate, initialRoute) ??
             delegate.notFoundRoute,
         navigatorKey: anchorRoute == null
             ? null
             : Get.nestedKey(anchorRoute)?.navigatorKey,
         delegate: delegate,
       );

  /// Resolves the page rendered for an outlet's `initialRoute` through the
  /// synchronously-resolvable part of the middleware pipeline.
  ///
  /// The router delegate never navigates to an outlet's `initialRoute` (the
  /// page is rendered directly whenever the outlet picks no pages), so
  /// [GetMiddleware.redirectDelegate] would otherwise never run for it.
  /// Middlewares run in ascending [GetMiddleware.priority] order, mirroring
  /// the delegate's own pipeline. Because this resolution happens during
  /// build, asynchronous [GetMiddleware.redirectDelegate] results cannot be
  /// awaited and keep the original target; synchronous results — including
  /// the default bridge to [GetMiddleware.redirect] — are honored. A
  /// middleware stopping the navigation (returning `null`) resolves to
  /// `null`, which callers degrade to [GetDelegate.notFoundRoute].
  static GetPage? _resolveInitialPage(
    GetDelegate delegate,
    String initialRoute,
  ) {
    var decoder = delegate.matchRoute(
      initialRoute,
      arguments: PageSettings(Uri.parse(initialRoute)),
    );
    final visited = <String>{};
    while (true) {
      final page = decoder.route;
      if (page == null) return null;
      // A middleware redirect cycle can never settle; degrade to the
      // not-found page instead of looping forever during build.
      if (!visited.add(page.name)) return null;
      final middlewares = List.of(page.middlewares)
        ..sort((a, b) => a.priority.compareTo(b.priority));
      RouteDecoder? next;
      for (final middleware in middlewares) {
        final resolved = middleware.redirectDelegate(decoder);
        if (resolved is Future) continue;
        if (resolved == null) return null;
        if (resolved.pageSettings?.name != decoder.pageSettings?.name) {
          next = resolved;
          break;
        }
      }
      if (next == null) return page;
      decoder = next;
    }
  }

  GetRouterOutlet.pickPages({
    super.key,
    Widget Function(GetDelegate delegate)? emptyWidget,
    GetPage Function(GetDelegate delegate)? emptyPage,
    required super.pickPages,
    void Function(Page<dynamic>)? onDidRemovePage,
    String? restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
    GetDelegate? delegate,
  }) : super(
         pageBuilder: (context, rDelegate, pages) {
           final pageRes = <GetPage?>[
             ...?pages,
             if (pages == null || pages.isEmpty) emptyPage?.call(rDelegate),
           ].whereType<GetPage>();

           if (pageRes.isNotEmpty) {
             return InheritedNavigator(
               navigatorKey:
                   navigatorKey ?? Get.rootController.rootDelegate.navigatorKey,
               child: _OutletHeroControllerScope(
                 child: GetNavigator(
                   restorationScopeId: restorationScopeId,
                   onDidRemovePage: onDidRemovePage ?? _ignoreDidRemovePage,
                   pages: pageRes.toList(),
                   key: navigatorKey,
                 ),
               ),
             );
           }
           return (emptyWidget?.call(rDelegate) ?? const SizedBox.shrink());
         },
         delegate: delegate ?? Get.rootController.rootDelegate,
       );

  GetRouterOutlet.builder({
    super.key,
    required super.builder,
    String? route,
    GetDelegate? routerDelegate,
  }) : super.builder(
         delegate:
             routerDelegate ??
             (route != null
                 ? Get.nestedKey(route)
                 : Get.rootController.rootDelegate),
       );
}

/// Default `onDidRemovePage` handler for nested outlet navigators.
///
/// The Navigator pages API requires a removal callback; a nested outlet's
/// page stack is derived declaratively from the router delegate's history,
/// so a page leaving the picked stack needs no bookkeeping here — the
/// delegate already reflects the change that caused the removal.
void _ignoreDidRemovePage(Page<dynamic> page) {}

/// The tree branch an outlet anchored at [anchorRoute] should render from.
///
/// Prefers the deepest entry of [delegate]'s navigation history whose
/// branch contains the anchor, so that a nested outlet keeps showing its
/// current child while an unrelated route (e.g. a sibling top-level page)
/// sits on top of the history. Falls back to [config]'s branch when no
/// history entry contains the anchor.
List<GetPage> _anchorBranch(
  RouteDecoder config,
  String anchorRoute,
  GetDelegate delegate,
) {
  final activePages = delegate.activePages;
  for (var i = activePages.length - 1; i >= 0; i--) {
    final branch = activePages[i].currentTreeBranch;
    if (branch.any((page) => page.name == anchorRoute)) {
      return branch;
    }
  }
  return config.currentTreeBranch;
}

/// Truncates [pages] after the first page that itself anchors a deeper
/// nested outlet (a registered nested navigation key), keeping that page
/// but dropping its descendants.
///
/// Descendant pages are hosted by the deeper outlet's navigator; leaking
/// them into the outer outlet as well would stack them over the deeper
/// outlet's host page and render them twice.
Iterable<GetPage> _stopAfterNestedOutletAnchor(
  Iterable<GetPage> pages,
  String anchorRoute,
) {
  final result = <GetPage>[];
  for (final page in pages) {
    result.add(page);
    if (page.name != anchorRoute &&
        Get.rootController.keys.containsKey(page.name)) {
      break;
    }
  }
  return result;
}

/// Hosts a persistent [HeroController] scoped to a nested outlet navigator.
///
/// `MaterialApp.router`/`CupertinoApp.router` install a single
/// [HeroControllerScope] above the root navigator. Without an inner scope,
/// every nested outlet navigator would attach that same controller and
/// Flutter reports "A HeroController can not be shared by multiple
/// Navigators". Owning the controller in a [State] keeps hero flight state
/// alive across outlet rebuilds.
class _OutletHeroControllerScope extends StatefulWidget {
  const _OutletHeroControllerScope({required this.child});

  final Widget child;

  @override
  State<_OutletHeroControllerScope> createState() =>
      _OutletHeroControllerScopeState();
}

class _OutletHeroControllerScopeState
    extends State<_OutletHeroControllerScope> {
  final HeroController _controller = MaterialApp.createMaterialHeroController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(controller: _controller, child: widget.child);
  }
}

class InheritedNavigator extends InheritedWidget {
  const InheritedNavigator({
    super.key,
    required super.child,
    required this.navigatorKey,
  });
  final GlobalKey<NavigatorState> navigatorKey;

  static InheritedNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedNavigator>();
  }

  @override
  bool updateShouldNotify(InheritedNavigator oldWidget) {
    return true;
  }
}

extension NavKeyExt on BuildContext {
  GlobalKey<NavigatorState>? get parentNavigatorKey {
    return InheritedNavigator.of(this)?.navigatorKey;
  }
}

extension PagesListExt on List<GetPage> {
  /// Returns the route and all following routes after the given route.
  Iterable<GetPage> pickFromRoute(String route) {
    return skipWhile((value) => value.name != route);
  }

  /// Returns the routes after the given route.
  Iterable<GetPage> pickAfterRoute(String route) {
    // If the provided route is root, we take the first route after root.
    if (route == '/') {
      return pickFromRoute(route).skip(1).take(1);
    }
    // Otherwise, we skip the route and take all routes after it.
    return pickFromRoute(route).skip(1);
  }
}

typedef NavigatorItemBuilderBuilder =
    Widget Function(BuildContext context, List<String> routes, int index);

class IndexedRouteBuilder<T> extends StatelessWidget {
  const IndexedRouteBuilder({
    super.key,
    required this.builder,
    required this.routes,
  });
  final List<String> routes;
  final NavigatorItemBuilderBuilder builder;

  // Method to get the current index based on the route
  int _getCurrentIndex(String currentLocation) {
    for (int i = 0; i < routes.length; i++) {
      if (currentLocation.startsWith(routes[i])) {
        return i;
      }
    }
    return 0; // default index
  }

  @override
  Widget build(BuildContext context) {
    final location = context.location;
    final index = _getCurrentIndex(location);

    return builder(context, routes, index);
  }
}

mixin RouterListenerMixin<T extends StatefulWidget> on State<T> {
  RouterDelegate? delegate;

  void _listener() {
    setState(() {});
  }

  VoidCallback? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();
    final router = Router.of(context);
    delegate ??= router.routerDelegate as GetDelegate;

    delegate?.addListener(_listener);
    disposer = () => delegate?.removeListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    disposer?.call();
  }
}

class RouterListenerInherited extends InheritedWidget {
  const RouterListenerInherited({super.key, required super.child});

  static RouterListenerInherited? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RouterListenerInherited>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class RouterListener extends StatefulWidget {
  const RouterListener({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<RouterListener> createState() => RouteListenerState();
}

class RouteListenerState extends State<RouterListener>
    with RouterListenerMixin {
  @override
  Widget build(BuildContext context) {
    return RouterListenerInherited(child: Builder(builder: widget.builder));
  }
}

class BackButtonCallback extends StatefulWidget {
  const BackButtonCallback({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<BackButtonCallback> createState() => RouterListenerState();
}

class RouterListenerState extends State<BackButtonCallback>
    with RouterListenerMixin {
  late ChildBackButtonDispatcher backButtonDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = Router.of(context);
    backButtonDispatcher = router.backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    backButtonDispatcher.takePriority();
    return widget.builder(context);
  }
}
