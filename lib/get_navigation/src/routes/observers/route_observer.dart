import 'package:flutter/widgets.dart';

import '../../../../get_core/get_core.dart';
import '../../../get_navigation.dart';
import '../../dialog/dialog_route.dart';
import '../../router_report.dart';

/// Extracts the name of a route based on it's instance type
/// or null if not possible.
String? _extractRouteName(Route? route) {
  if (route?.settings.name != null) {
    return route!.settings.name;
  }

  if (route is GetPageRoute) {
    return route.routeName;
  }

  if (route is GetDialogRoute) {
    return 'DIALOG ${route.hashCode}';
  }

  if (route is GetModalBottomSheetRoute) {
    return 'BOTTOMSHEET ${route.hashCode}';
  }

  return null;
}

class GetObserver extends NavigatorObserver {
  final Function(Routing?)? routing;

  final Routing? _routeSend;

  GetObserver([this.routing, this._routeSend]);

  /// Schedules dependency cleanup for a route that does not report its own
  /// disposal to the [RouterReportManager] — any route not created by GetX,
  /// e.g. Flutter's `showModalBottomSheet`/`showDialog` overlays or an
  /// imperative `Navigator.push` route.
  ///
  /// GetX-created routes ([GetPageRoute], [GetDialogRoute] and
  /// [GetModalBottomSheetRoute]) report their disposal themselves, which
  /// releases the dependencies registered while they were the current
  /// route. Dependencies registered inside a native overlay (e.g. a
  /// `Get.put` in a `showModalBottomSheet` builder) are linked to the
  /// native route, which never reports back, so without this hook they
  /// would leak after the overlay is dismissed (#2439). Cleanup runs once
  /// the route is disposed — after its exit transition — so widgets still
  /// animating out never observe deleted dependencies.
  void _reportDisposalOfNonReportingRoute(Route route) {
    if (route is PageRouteReportMixin ||
        route is GetDialogRoute ||
        route is GetModalBottomSheetRoute) {
      return;
    }
    if (route is TransitionRoute) {
      route.completed.whenComplete(() {
        RouterReportManager.instance.reportRouteDispose(route);
      });
    } else {
      RouterReportManager.instance.reportRouteDispose(route);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final currentRoute = _RouteData.ofRoute(route);
    final newRoute = _RouteData.ofRoute(previousRoute);

    if (currentRoute.isBottomSheet || currentRoute.isDialog) {
      Get.log("CLOSE ${currentRoute.name}");
    } else if (currentRoute.isGetPageRoute) {
      Get.log("CLOSE TO ROUTE ${currentRoute.name}");
    }
    if (previousRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(previousRoute);
    }

    if (route is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(route);
    }
    _reportDisposalOfNonReportingRoute(route);

    // Here we use a 'inverse didPush set', meaning that we use
    // previous route instead of 'route' because this is
    // a 'inverse push'
    _routeSend?.update((value) {
      // Only popping a page route may change current/previous values.
      // Overlay pops (dialogs/bottom sheets) leave them untouched so that
      // synthetic overlay names never leak into the routing history.
      if (route is PageRoute) {
        if (previousRoute is PageRoute) {
          value.current = _extractRouteName(previousRoute) ?? '';
          value.previous = currentRoute.name ?? '';
        } else if (value.previous.isNotEmpty) {
          // The revealed route is pageless (e.g. a bottom sheet under the
          // popped page), so fall back to the last known page below it.
          value.current = value.previous;
          value.previous = currentRoute.name ?? '';
        }
      }

      value.args = previousRoute?.settings.arguments;
      value.route = previousRoute;
      value.isBack = true;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });

    routing?.call(_routeSend);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    if (newRoute.isBottomSheet || newRoute.isDialog) {
      Get.log("OPEN ${newRoute.name}");
    } else if (newRoute.isGetPageRoute) {
      Get.log("GOING TO ROUTE ${newRoute.name}");
    }

    RouterReportManager.instance.reportCurrentRoute(route);
    _routeSend?.update((value) {
      // Only page routes are allowed to change current/previous values.
      // Overlay pushes (dialogs/bottom sheets) leave them untouched so that
      // synthetic overlay names never leak into the routing history.
      if (route is PageRoute) {
        final previousRouteName = previousRoute is PageRoute
            ? _extractRouteName(previousRoute)
            : previousRoute != null && value.current.isNotEmpty
            ? value.current
            : null;
        if (previousRouteName != null) {
          value.previous = previousRouteName;
        }
        value.current = newRoute.name ?? '';
      }

      value.args = route.settings.arguments;
      value.route = route;
      value.isBack = false;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet
          ? true
          : value.isBottomSheet ?? false;
      value.isDialog = newRoute.isDialog ? true : value.isDialog ?? false;
    });

    if (routing != null) {
      routing!(_routeSend);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _extractRouteName(route);
    final currentRoute = _RouteData.ofRoute(route);
    final previousRouteName = _extractRouteName(previousRoute);

    Get.log("REMOVING ROUTE $routeName");
    Get.log("PREVIOUS ROUTE $previousRouteName");

    _routeSend?.update((value) {
      // A pages-API update (e.g. offAllNamed) reports the removal of every
      // superseded page after the push of the new top page; the bottom-most
      // removed route has no previous route, and letting it clobber the
      // route/previous recorded by that push would make `Get.rawRoute`
      // observed from a new page's controller null (#1237).
      if (previousRoute != null) value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? '';
      value.previous = previousRouteName ?? value.previous;
      value.isBottomSheet = currentRoute.isBottomSheet
          ? false
          : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    if (route is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(route);
    }
    _reportDisposalOfNonReportingRoute(route);
    routing?.call(_routeSend);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _extractRouteName(newRoute);
    final oldName = _extractRouteName(oldRoute);
    final currentRoute = _RouteData.ofRoute(oldRoute);

    Get.log("REPLACE ROUTE $oldName");
    Get.log("NEW ROUTE $newName");

    if (newRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(newRoute);
    }

    _routeSend?.update((value) {
      // Only PageRoute is allowed to change current value
      if (newRoute is PageRoute) {
        value.current = newName ?? '';
      }

      value.args = newRoute?.settings.arguments;
      value.route = newRoute;
      value.isBack = false;
      value.removed = '';
      value.previous = oldName ?? '';
      value.isBottomSheet = currentRoute.isBottomSheet
          ? false
          : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });
    if (oldRoute is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(oldRoute);
    }

    routing?.call(_routeSend);
  }
}

class Routing {
  String current;
  String previous;
  Object? args;
  String removed;
  Route<dynamic>? route;
  bool? isBack;
  bool? isBottomSheet;
  bool? isDialog;

  Routing({
    this.current = '',
    this.previous = '',
    this.args,
    this.removed = '',
    this.route,
    this.isBack,
    this.isBottomSheet,
    this.isDialog,
  });

  void update(void Function(Routing value) fn) {
    fn(this);
  }
}

/// This is basically a util for rules about 'what a route is'
class _RouteData {
  final bool isGetPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;

  const _RouteData({
    required this.name,
    required this.isGetPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) {
    return _RouteData(
      name: _extractRouteName(route),
      isGetPageRoute: route is GetPageRoute,
      isDialog: route is GetDialogRoute,
      isBottomSheet: route is GetModalBottomSheetRoute,
    );
  }
}
