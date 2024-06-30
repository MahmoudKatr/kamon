import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences; //declare
  static void cacheInitialization() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  //method are available in shared pref

  static Future<bool> setData(
      {required String key, required dynamic value}) async {
    if (value is bool) {
      await sharedPreferences.setBool(key, value);
      return true;
    }
    if (value is String) {
      await sharedPreferences.setString(key, value);
      return true;
    }
    if (value is int) {
      await sharedPreferences.setInt(key, value);
      return true;
    }
    if (value is double) {
      await sharedPreferences.setDouble(key, value);
      return true;
    }
    return false;
  }

  //get data from shared pref
  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  //delee data from shared pref
  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }
  //you can found method to clear all data in shared
}
