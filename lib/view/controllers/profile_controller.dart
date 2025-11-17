import 'dart:io';
import 'package:get/get.dart';
import 'package:kavana_app/data/models/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/core/session.dart';

class ProfileController extends GetxController {
  final _profileImagePath = Rxn<String>();
  final _userName = ''.obs;
  final _userEmail = ''.obs;

  String? get profileImagePath => _profileImagePath.value;
  String get userName => _userName.value;
  String get userEmail => _userEmail.value;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final imagePath = await UserPreferences.getProfileImagePath();
    final name = await UserPreferences.getUserName();
    final email = await UserPreferences.getUserEmail();

    _profileImagePath.value = imagePath;
    _userName.value = name ?? '';
    _userEmail.value = email ?? '';
    
    // Jika UserPreferences kosong, ambil dari Session
    if (_userName.value.isEmpty || _userEmail.value.isEmpty) {
      final user = await Session.getUser();
      if (user != null) {
        _userName.value = user.name;
        _userEmail.value = user.email;
        // Simpan ke UserPreferences untuk next time
        await UserPreferences.saveUserName(user.name);
        await UserPreferences.saveUserEmail(user.email);
        await UserPreferences.saveUserId(user.id);
      }
    }
  }

  Future<void> updateProfileImage(String? imagePath) async {
    _profileImagePath.value = imagePath;
  }

  Future<void> updateUserName(String name) async {
    _userName.value = name;
  }

  Future<void> updateUserEmail(String email) async {
    _userEmail.value = email;
  }

  void clear() {
    _profileImagePath.value = null;
    _userName.value = '';
    _userEmail.value = '';
  }

  Widget getProfileImage({
    double size = 48,
    double borderWidth = 0,
  }) {
    return Obx(() {
      final imagePath = _profileImagePath.value;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(width: borderWidth, color: AppColor.primary)
              : null,
          image: imagePath != null && File(imagePath).existsSync()
              ? DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                )
              : const DecorationImage(
                  image: AssetImage('assets/images/profile.png'),
                  fit: BoxFit.cover,
                ),
        ),
      );
    });
  }
}