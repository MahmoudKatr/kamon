import 'package:flutter/material.dart';
import 'package:kamon/Features/Splash/presentation/views/widgets/splash_view_body.dart';
import 'package:kamon/constant.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kPrimaryColor,
      body: SplashViewbody(),
    );
  }
}
