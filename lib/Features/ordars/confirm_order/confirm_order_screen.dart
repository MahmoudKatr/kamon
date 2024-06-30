import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kamon/Features/home/data/get_location.dart';

class BranchLocator extends StatefulWidget {
  const BranchLocator({super.key});

  @override
  _BranchLocatorState createState() => _BranchLocatorState();
}

class _BranchLocatorState extends State<BranchLocator> {
  final LocationService _locationService = LocationService();
  String _branchMessage = 'Loading...';

  final Map<String, List<double>> branches = {
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Port Said': [31.2653, 32.3019],
  };

  @override
  void initState() {
    super.initState();
    _determineClosestBranch();
  }

  Future<void> _determineClosestBranch() async {
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
          _branchMessage = 'Welcome to our $closestBranch branch!';
        } else {
          _branchMessage = 'You are out of the delivery area.';
        }
      });
    } catch (e) {
      setState(() {
        _branchMessage = 'Failed to determine your location.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Locator'),
      ),
      body: Center(
        child: Text(
          _branchMessage,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: BranchLocator(),
  ));
}
