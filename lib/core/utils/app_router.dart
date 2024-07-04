import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:kamon/Features/Splash/presentation/views/splash_view.dart';
import 'package:kamon/Features/app_layout/screens/app_layout_screen.dart';
import 'package:kamon/Features/auth/UI/login_screen.dart';
import 'package:kamon/Features/menu/model/menu_model.dart';
import 'package:kamon/Features/menu/presentation/item_screen.dart';
import 'package:kamon/Features/ordars/cart_screen.dart';
import 'package:kamon/Features/ordars/data/cart_provider.dart';
import 'package:provider/provider.dart';

abstract class AppRouter {
  static const kHomeView = '/homeView';
  static const kItemScreen = '/itemScreen';
  static const kCartScreen = '/cartScreen';
  static const kLoginScreen = '/loginScreen';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kHomeView,
        builder: (context, state) => const AppLayoutScreen(
          branchId: 1,
          branchLocation: '',
        ),
      ),
      GoRoute(
        path: kLoginScreen,
        builder: (context, state) => const LoginScreen(
          branchLocation: '',
        ),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) {
          final String jsonString = state.extra as String;
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final menuItem = MenuItem.fromJson(jsonMap);

          return ItemScreen(
            menuItem: menuItem,
          );
        },
      ),
      GoRoute(
        path: kCartScreen,
        builder: (context, state) => Consumer<CartProvider>(
          builder: (context, cart, child) => CartScreen(cart: cart),
        ),
      ),
    ],
  );
}
