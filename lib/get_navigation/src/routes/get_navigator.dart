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
         observers: [
           // GetObserver(null, Get.routing),
           HeroController(),
           ...?observers,
         ],
         transitionDelegate:
             transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
       );
}
