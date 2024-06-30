import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kamon/Features/home/data/get_location.dart';
import 'package:kamon/core/utils/app_router.dart';

class SplashViewbody extends StatefulWidget {
  const SplashViewbody({super.key});

  @override
  State<SplashViewbody> createState() => _SplashViewbodyState();
}

class _SplashViewbodyState extends State<SplashViewbody>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> leftSlidingAnimation;
  late Animation<Offset> rightSlidingAnimation;
  final LocationService _locationService = LocationService();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String branchLocation = 'Unknown';
  int branchId = 0;

  final Map<String, List<double>> branches = {
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
  };

  final Map<String, int> branchIds = {
    'Cairo': 3,
    'Alexandria': 1,
    'Port Said': 2,
  };

  @override
  void initState() {
    super.initState();
    initAnimated();
    checkTokenValidity();
  }

  Future<void> checkTokenValidity() async {
    String? token = await secureStorage.read(key: 'token');
    if (token == null || JwtDecoder.isExpired(token)) {
      navigateToLoginScreen();
    } else {
      getBranchAndNearbyLocations();
    }
  }

  Future<void> getBranchAndNearbyLocations() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      double minDistance = double.infinity;
      String closestBranch = '';
      const double deliveryRadius = 10000.0; // 10 km in meters

      branches.forEach((branch, coordinates) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          coordinates[0],
          coordinates[1],
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestBranch = branch;
        }
      });

      setState(() {
        if (minDistance <= deliveryRadius) {
          branchLocation = closestBranch;
          branchId = branchIds[closestBranch]!;
          saveBranchId(branchId); // Save branchId to shared preferences
        } else {
          branchLocation = 'Out of delivery area';
        }
      });
    } catch (e) {
      setState(() {
        branchLocation = 'Failed to determine location';
      });
    } finally {
      navigateToHomePage();
    }
  }

  Future<void> saveBranchId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('branchId', id);
  }

  Future<int?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('branchId');
  }

  void navigateToLoginScreen() {
    Future.delayed(const Duration(seconds: 1), () {
      GoRouter.of(context).push(AppRouter.KLoginScreen);
    });
  }

  void navigateToHomePage() {
    Future.delayed(const Duration(seconds: 1), () {
      GoRouter.of(context).push(AppRouter.KHomeView);
    });
  }

  void initAnimated() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    leftSlidingAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0))
            .animate(animationController);
    rightSlidingAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(animationController);
    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 130,
          width: 140,
          child: Image.asset(
            'assets/images/logo.png', // Replace with your logo image asset path
          ),
        ),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center static image with padding
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: SizedBox(
                  height: 25,
                  width: 35,
                  child: Image.asset(
                    'assets/images/m.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Left sliding image with padding
              SlideTransition(
                position: leftSlidingAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 90), // Adjust width - half of center image
                  child: SizedBox(
                    height: 53,
                    width: 50,
                    child: Image.asset(
                      'assets/images/ka.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SlideTransition(
                position: rightSlidingAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(90, 5, 0, 0),
                  // Adjust width - half of center image
                  child: SizedBox(
                    height: 50,
                    width: 55, // Half of the total width
                    child: Image.asset(
                      'assets/images/on.png', // Replace with your right image asset path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AnimateText(slidingAnimation: leftSlidingAnimation),
      ],
    );
  }
}

class AnimateText extends StatelessWidget {
  const AnimateText({
    super.key,
    required this.slidingAnimation,
  });

  final Animation<Offset> slidingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: slidingAnimation,
        builder: (context, _) {
          return SlideTransition(
            position: slidingAnimation,
            child: const Text(
              "King of FooD ",
              textAlign: TextAlign.center,
            ),
          );
        });
  }
}
