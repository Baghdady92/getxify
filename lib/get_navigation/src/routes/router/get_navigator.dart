import 'package:flutter/widgets.dart';

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
         observers: [HeroController(), ...?observers],
         transitionDelegate:
             transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
       );
}
