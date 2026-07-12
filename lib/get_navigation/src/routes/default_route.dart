import 'package:flutter/cupertino.dart';

import '../../../getxify.dart';
import '../router_report.dart';

/// Mixin that reports route lifecycle events to the [RouterReportManager].
///
/// This mixin should be applied to [State] classes to automatically report
/// when a route becomes active (initState) and when it's disposed.
mixin RouteReportMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

/// Mixin that reports route lifecycle events to the [RouterReportManager].
///
/// This mixin should be applied to [Route] classes to automatically report
/// when a route is installed and when it's disposed.
mixin PageRouteReportMixin<T> on Route<T> {
  @override
  void install() {
    super.install();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

class GetPageRoute<T> extends PageRoute<T>
    with GetPageRouteTransitionMixin<T>, PageRouteReportMixin {
  /// Creates a custom page route with GetX navigation features.
  ///
  /// This route supports custom transitions, bindings, middleware, and
  /// route reporting. It extends [PageRoute] and adds GetX-specific
  /// functionality for dependency injection and navigation control.
  ///
  /// The [page] or [settings] must be provided.
  GetPageRoute({
    super.settings,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.parameter,
    this.gestureWidth,
    this.curve,
    this.alignment,
    this.transition,
    this.popGesture,
    this.customTransition,
    this.barrierDismissible = false,
    this.barrierColor,
    BindingsInterface? binding,
    List<BindingsInterface> bindings = const [],
    this.binds,
    this.routeName,
    this.page,
    this.title,
    this.showCupertinoParallax = true,
    this.barrierLabel,
    this.maintainState = true,
    super.fullscreenDialog,
    this.middlewares,
    this.bindingOwnerNames,
  }) : bindings = (binding == null) ? bindings : [...bindings, binding],
       _middlewareRunner = MiddlewareRunner(middlewares);

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  /// The page builder function that creates the route's content.
  final GetPageBuilder? page;

  /// The name of the route for navigation and reporting.
  final String? routeName;

  /// Custom transition widget for this route.
  final CustomTransition? customTransition;

  /// List of binding interfaces to apply to this route.
  final List<BindingsInterface> bindings;

  /// The name of the page that declared each entry of [bindings], for
  /// entries inherited from ancestor pages during route-tree flattening.
  ///
  /// A page created from a nested route carries the merged bindings of its
  /// whole ancestor chain, so that deep-linking to it still registers the
  /// ancestors' dependencies. Dependencies registered by such an inherited
  /// binding are linked to the declaring ancestor's route (when installed)
  /// instead of this one, so they survive this route's disposal while the
  /// ancestor's view is still alive. Bindings absent from this map are
  /// treated as declared by this route's own page.
  final Map<BindingsInterface, String>? bindingOwnerNames;

  /// Route parameters passed as key-value pairs.
  final Map<String, String>? parameter;

  /// List of direct bindings to apply.
  final List<Bind>? binds;

  @override
  final bool showCupertinoParallax;

  @override
  final bool opaque;

  /// Whether the route can be popped with a gesture.
  final bool? popGesture;

  @override
  final bool barrierDismissible;

  /// The transition animation type for this route.
  final Transition? transition;

  /// The animation curve for the transition.
  final Curve? curve;

  /// The alignment for the transition animation.
  final Alignment? alignment;

  /// Middleware to run during route lifecycle.
  final List<GetMiddleware>? middlewares;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  /// The title of the route.
  @override
  final String? title;

  /// Function to determine the gesture width for swipe-to-pop.
  ///
  /// When null, the back gesture is recognized across the full page width.
  /// When provided, the gesture only starts within the returned width from
  /// the leading edge (widened as needed to cover a display notch).
  @override
  final double Function(BuildContext context)? gestureWidth;

  /// Runner for executing middleware callbacks.
  final MiddlewareRunner _middlewareRunner;

  @override
  void install() {
    super.install();
    final name = routeName;
    if (name != null) {
      RouterReportManager.instance.reportRouteName(name, this);
    }
  }

  @override
  void dispose() {
    // Leave the name registry before dependencies are torn down, so a
    // dependency resolved during disposal can never be linked to this
    // dying route through its name.
    final name = routeName;
    if (name != null) {
      RouterReportManager.instance.unreportRouteName(name, this);
    }
    super.dispose();
    _middlewareRunner.runOnPageDispose();
    _child = null;
  }

  Widget? _child;

  /// Runs [binding]'s `dependencies()`, attributing the registrations it
  /// creates to the page that declared it.
  ///
  /// The owner is looked up in [bindingOwnerNames] (an inherited ancestor
  /// binding is attributed to the ancestor page); a binding declared by
  /// this route's own page — or added later, e.g. by
  /// [GetMiddleware.onBindingsStart] — is attributed to [routeName].
  dynamic _runBindingDependencies(BindingsInterface binding) {
    final ownerName = bindingOwnerNames?[binding] ?? routeName;
    if (ownerName == null) return binding.dependencies();
    return RouterReportManager.instance.runWithBindingOwner(
      ownerName,
      binding.dependencies,
    );
  }

  /// Builds and caches the child widget with bindings applied.
  ///
  /// This method handles the dependency injection by running middleware
  /// and applying bindings before building the page widget. The result is
  /// cached to avoid rebuilding on every frame.
  ///
  /// Before running the bindings, this route reports itself as the current
  /// route so that dependencies instantiated while building its subtree are
  /// linked to it, even when multiple routes are pushed within the same
  /// frame.
  Widget _getChild() {
    if (_child != null) return _child!;

    RouterReportManager.instance.reportCurrentRoute(this);

    final localBinds = [...?binds];

    final bindingsToBind = _middlewareRunner.runOnBindingsStart(
      bindings.isNotEmpty ? bindings : localBinds,
    );

    final pageToBuild = _middlewareRunner.runOnPageBuildStart(page)!;

    if (bindingsToBind != null && bindingsToBind.isNotEmpty) {
      if (bindingsToBind is List<BindingsInterface>) {
        for (final item in bindingsToBind) {
          final dep = _runBindingDependencies(item);
          if (dep is List<Bind>) {
            _child = Binds(
              binds: dep,
              child: _middlewareRunner.runOnPageBuilt(pageToBuild()),
            );
          }
        }
      } else if (bindingsToBind is List<Bind>) {
        _child = Binds(
          binds: bindingsToBind,
          child: _middlewareRunner.runOnPageBuilt(pageToBuild()),
        );
      }
    }

    return _child ??= _middlewareRunner.runOnPageBuilt(pageToBuild());
  }

  @override
  Widget buildContent(BuildContext context) {
    return _getChild();
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
