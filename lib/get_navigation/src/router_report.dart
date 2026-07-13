import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../getxify.dart';

class RouterReportManager<T> {
  /// Holds a reference to `Get.reference` when the Instance was
  /// created to manage the memory.
  final Map<T?, List<String>> _routesKey = {};

  /// The installed routes grouped by their concrete route name
  /// (e.g. `/home/products`), in installation order.
  ///
  /// Used to link a dependency declared by a page's binding to the route of
  /// the page that declared it: when a deep link instantiates a nested leaf
  /// page, the leaf runs the merged bindings of its whole ancestor chain,
  /// and a dependency first resolved under the leaf would otherwise be
  /// linked to the leaf route and die with it while the ancestor's view is
  /// still visible.
  final Map<String, List<T>> _routesByName = {};

  /// Stores the onClose() references of instances created with `Get.create()`
  /// using the `Get.reference`.
  /// Experimental feature to keep the lifecycle and memory management with
  /// non-singleton instances.
  final Map<T?, HashSet<Function>> _routesByCreate = {};

  static RouterReportManager? _instance;

  RouterReportManager._();

  static RouterReportManager get instance =>
      _instance ??= RouterReportManager._();

  static void dispose() {
    _instance = null;
  }

  void printInstanceStack() {
    Get.log(_routesKey.toString());
  }

  T? _current;

  // ignore: use_setters_to_change_properties
  void reportCurrentRoute(T newRoute) {
    _current = newRoute;
  }

  /// Registers [route] as an installed route named [name], making it a
  /// candidate target for [reportDependencyLinkedToRoute] calls that carry
  /// the same `ownerRouteName`.
  void reportRouteName(String name, T route) {
    (_routesByName[name] ??= <T>[]).add(route);
  }

  /// Removes [route] from the name registry when it is disposed.
  void unreportRouteName(String name, T route) {
    final routes = _routesByName[name];
    if (routes == null) return;
    routes.remove(route);
    if (routes.isEmpty) _routesByName.remove(name);
  }

  /// The route name owning the binding whose `dependencies()` is currently
  /// executing, or `null` outside of a page-binding run.
  String? _bindingOwnerName;

  /// The route name new dependency registrations should be attributed to,
  /// or `null` when none is in scope. Read by the instance manager when a
  /// registration is created.
  String? get currentBindingOwnerName => _bindingOwnerName;

  /// Runs [body] (a binding's `dependencies()`) attributing every
  /// dependency registration it creates to the route named
  /// [ownerRouteName], so that the dependency is later linked to that
  /// route even when its first resolution happens while another route
  /// (e.g. a deep-linked descendant) is current.
  R runWithBindingOwner<R>(String ownerRouteName, R Function() body) {
    final previous = _bindingOwnerName;
    _bindingOwnerName = ownerRouteName;
    try {
      return body();
    } finally {
      _bindingOwnerName = previous;
    }
  }

  /// The most recently installed live route named [name], or `null`.
  T? _latestRouteNamed(String name) {
    final routes = _routesByName[name];
    if (routes == null || routes.isEmpty) return null;
    return routes.last;
  }

  /// Whether [route] is a page route whose concrete name is [name].
  bool _routeIsNamed(T? route, String name) {
    if (route == null) return false;
    if (route is GetPageRoute) return route.routeName == name;
    if (route is Route) return (route as Route).settings.name == name;
    return false;
  }

  /// Links a Class instance [S] (or [tag]) to the current route.
  /// Requires usage of `GetMaterialApp`.
  ///
  /// When the registration being resolved was declared by a page binding
  /// ([ownerRouteName] is not null) and the current route is not the
  /// declaring page's route, the dependency is linked to the declaring
  /// page's installed route instead — so a parent page's controller first
  /// resolved under a deep-linked child route still belongs to the parent
  /// route and survives the child's disposal. When no route named
  /// [ownerRouteName] is installed (e.g. the parent page was never
  /// mounted), the link falls back to the current route.
  void reportDependencyLinkedToRoute(
    String dependencyKey, {
    String? ownerRouteName,
  }) {
    var target = _current;
    if (ownerRouteName != null && !_routeIsNamed(target, ownerRouteName)) {
      target = _latestRouteNamed(ownerRouteName) ?? target;
    }
    if (target == null) return;
    if (_routesKey.containsKey(target)) {
      _routesKey[target]!.add(dependencyKey);
    } else {
      _routesKey[target] = <String>[dependencyKey];
    }
  }

  void clearRouteKeys() {
    _routesKey.clear();
    _routesByCreate.clear();
    _routesByName.clear();
  }

  void appendRouteByCreate(GetLifeCycleMixin i) {
    _routesByCreate[_current] ??= HashSet<Function>();
    _routesByCreate[_current]!.add(i.onDelete);
  }

  void reportRouteDispose(T disposed) {
    if (Get.smartManagement != SmartManagement.onlyBuilder) {
      // Engine.instance.addPostFrameCallback((_) {
      // Future.microtask(() {
      _removeDependencyByRoute(disposed);
      // });
    }
  }

  void reportRouteWillDispose(T disposed) {
    final keysToRemove = <String>[];

    _routesKey[disposed]?.forEach(keysToRemove.add);

    /// Removes `Get.create()` instances registered in `routeName`.
    if (_routesByCreate.containsKey(disposed)) {
      for (final onClose in _routesByCreate[disposed]!) {
        // assure the [DisposableInterface] instance holding a reference
        // to onClose() wasn't disposed.
        onClose();
      }
      _routesByCreate[disposed]!.clear();
      _routesByCreate.remove(disposed);
    }

    for (final element in keysToRemove) {
      Get.markAsDirty(key: element);

      //_routesKey.remove(element);
    }

    keysToRemove.clear();
  }

  /// Clears from memory registered Instances associated with [routeName] when
  /// using `Get.smartManagement` as [SmartManagement.full] or
  /// [SmartManagement.keepFactory]
  /// Meant for internal usage of `GetPageRoute` and `GetDialogRoute`
  ///
  /// Deletion of an instance that still has widget subscribers is deferred
  /// to the end of the frame by [Inst.deleteRouteDependency]: subscribers
  /// remaining after the disposed route's subtree unmounted belong to
  /// still-mounted widgets of other routes (e.g. a lower route's view that
  /// created the controller while this route was topmost), and the instance
  /// they depend on is kept alive instead of being deleted under them.
  void _removeDependencyByRoute(T routeName) {
    final keysToRemove = <String>[];

    _routesKey[routeName]?.forEach(keysToRemove.add);

    /// Removes `Get.create()` instances registered in `routeName`.
    if (_routesByCreate.containsKey(routeName)) {
      for (final onClose in _routesByCreate[routeName]!) {
        // assure the [DisposableInterface] instance holding a reference
        // to onClose() wasn't disposed.
        onClose();
      }
      _routesByCreate[routeName]!.clear();
      _routesByCreate.remove(routeName);
    }

    for (final element in keysToRemove) {
      Get.deleteRouteDependency(element);
    }

    _routesKey.remove(routeName);

    keysToRemove.clear();
  }
}
