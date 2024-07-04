import 'package:flutter/material.dart';
import 'package:kamon/Features/ordars/data/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:kamon/core/utils/app_router.dart';
import 'package:kamon/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamon/Features/auth/auth_login/login_cubit.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        BlocProvider(create: (_) => LoginCubit(Dio())), // Add LoginCubit here
      ],
      child: const Kamon(),
    ),
  );
}

class Kamon extends StatelessWidget {
  const Kamon({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: kSecondaryColor,
      ),
    );
  }
}
