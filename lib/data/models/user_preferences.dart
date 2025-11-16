import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static const String _keyProfileImage = 'profile_image_path';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';

  // Save profile image path
  static Future<bool> saveProfileImagePath(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyProfileImage, imagePath);
    } catch (e) {
      print('Error saving profile image path: $e');
      return false;
    }
  }

  // Get profile image path
  static Future<String?> getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyProfileImage);
    } catch (e) {
      print('Error getting profile image path: $e');
      return null;
    }
  }

  // Save user name
  static Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyUserName, name);
    } catch (e) {
      print('Error saving user name: $e');
      return false;
    }
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Save user email
  static Future<bool> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyUserEmail, email);
    } catch (e) {
      print('Error saving user email: $e');
      return false;
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Save user id
  static Future<bool> saveUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_keyUserId, userId);
    } catch (e) {
      print('Error saving user id: $e');
      return false;
    }
  }

  // Get user id
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e) {
      print('Error getting user id: $e');
      return null;
    }
  }

  // Clear all preferences
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing preferences: $e');
      return false;
    }
  }

  // Delete profile image
  static Future<bool> deleteProfileImage() async {
    try {
      final imagePath = await getProfileImagePath();
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyProfileImage);
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }
}