import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class KamonPermissions {
  static Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      // Handle the case when permission is denied
      debugPrint('Location permission denied');
    } else if (status.isGranted) {
      debugPrint('Location permission granted');
    }
  }
}
