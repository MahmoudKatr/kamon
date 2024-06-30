import 'package:flutter/material.dart';
import 'package:kamon/Features/Splash/presentation/views/splash_view.dart';
import 'package:kamon/Features/auth/UI/login_screen.dart';
import 'package:kamon/config/routes/app_routes.dart';
import 'package:kamon/core/utils/app_strings.dart';

/// Application routes
class AppRoutes {
  /// this method is used to generate the routes
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SplashView();
          },
          settings: const RouteSettings(name: Routes.initialRoute),
        );

      case Routes.appLayoutRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const LoginScreen(
              branchLocation: '',
            );
          },
          settings: const RouteSettings(name: Routes.appLayoutRoute),
        );

      default:
        return undefinedRoute();
    }
  }

  /// this method is used to undefinedRoute the routes
  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('undefinedRoute'),
        ),
      ),
      settings: const RouteSettings(name: AppStrings.noRouteFound),
    );
  }
}
