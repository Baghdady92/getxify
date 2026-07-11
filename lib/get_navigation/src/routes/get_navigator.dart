import 'package:flutter/widgets.dart';

/// A [Navigator] preconfigured for GetX's Router (Navigator 2.0) flow.
///
/// Hero support comes from the enclosing [HeroControllerScope] installed by
/// `MaterialApp.router`/`CupertinoApp.router` (which `GetMaterialApp` and
/// `GetCupertinoApp` always build). No [HeroController] is added to
/// [observers] here: the scope's controller is already attached to this
/// navigator by the framework, and registering a second controller would
/// start two hero flights per transition — doubled heroes and
/// `Hero` divert assertion failures during back gestures.
class GetNavigator extends Navigator {
  GetNavigator({
    super.key,
    super.onDidRemovePage,
    required super.pages,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
  }) : super(
         observers: [...?observers],
         transitionDelegate:
             transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
       );
}
