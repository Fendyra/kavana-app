import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _kunciGambarProfil = 'path_gambar_profil';
  static const String _kunciNamaPengguna = 'nama_pengguna';
  static const String _kunciEmailPengguna = 'email_pengguna';
  static const String _kunciIdPengguna = 'id_pengguna';

  static Future<bool> saveProfileImagePath(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_kunciGambarProfil, imagePath);
    } catch (e) {
      print('Error menyimpan path gambar profil: $e');
      return false;
    }
  }

  static Future<String?> getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kunciGambarProfil);
    } catch (e) {
      print('Error mendapatkan path gambar profil: $e');
      return null;
    }
  }

  static Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_kunciNamaPengguna, name);
    } catch (e) {
      print('Error menyimpan nama pengguna: $e');
      return false;
    }
  }

  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kunciNamaPengguna);
    } catch (e) {
      print('Error mendapatkan nama pengguna: $e');
      return null;
    }
  }

  static Future<bool> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_kunciEmailPengguna, email);
    } catch (e) {
      print('Error menyimpan email pengguna: $e');
      return false;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kunciEmailPengguna);
    } catch (e) {
      print('Error mendapatkan email pengguna: $e');
      return null;
    }
  }

  static Future<bool> saveUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_kunciIdPengguna, userId);
    } catch (e) {
      print('Error menyimpan id pengguna: $e');
      return false;
    }
  }

  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_kunciIdPengguna);
    } catch (e) {
      print('Error mendapatkan id pengguna: $e');
      return null;
    }
  }

  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error menghapus preferensi: $e');
      return false;
    }
  }

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
      return await prefs.remove(_kunciGambarProfil);
    } catch (e) {
      print('Error menghapus gambar profil: $e');
      return false;
    }
  }
}