import 'package:getxify/getxify.dart';

import '../../services/auth_service.dart';
import '../routes/app_pages.dart';

/// Middleware to ensure user is authenticated before accessing a route
/// Redirects to login page if user is not authenticated
class EnsureAuthMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    // Check if user is authenticated
    if (!AuthService.to.isLoggedInValue) {
      // Redirect to login with the intended route as a parameter
      final newRoute = Routes.LOGIN_THEN(route.pageSettings!.name);
      return RouteDecoder.fromRoute(newRoute);
    }
    return await super.redirectDelegate(route);
  }
}

/// Middleware to ensure user is NOT authenticated before accessing a route
/// Prevents access to login/register pages if user is already authenticated
class EnsureNotAuthedMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    if (AuthService.to.isLoggedInValue) {
      // User is already authenticated, prevent access to auth screen
      return null;

      // Alternatively, redirect to another screen like profile
      // return RouteDecoder.fromRoute(Routes.PROFILE);
    }
    return await super.redirectDelegate(route);
  }
}
