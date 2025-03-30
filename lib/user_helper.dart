import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  // Get the current user ID
  static Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt("userId");
  return userId?.toString();
  }
  
  // Get the current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }
  
  // Get the auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return token != null && token.isNotEmpty;
  }
  
  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userEmail");
    await prefs.remove("userId");
  }
}