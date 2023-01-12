import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/container.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(List<PageRouteInfo<dynamic>> pendingRoutes, StackRouter router) async {
    return getIt<Auth>().isAuthenticated;
  }
}
