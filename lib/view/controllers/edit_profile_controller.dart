import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/data/models/user_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class EditProfileController extends GetxController {
  final _state = EditProfileState(
    message: '',
    statusRequest: StatusRequest.init,
    profileImagePath: null,
    userName: '',
  ).obs;

  EditProfileState get state => _state.value;
  set state(EditProfileState n) => _state.value = n;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Check if running on iOS Simulator
  bool get isSimulator {
    if (!kIsWeb && Platform.isIOS) {
      return !Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') &&
             defaultTargetPlatform == TargetPlatform.iOS;
    }
    return false;
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    state = state.copyWith(statusRequest: StatusRequest.loading);

    try {
      final imagePath = await UserPreferences.getProfileImagePath();
      final userName = await UserPreferences.getUserName();

      state = state.copyWith(
        statusRequest: StatusRequest.success,
        profileImagePath: imagePath,
        userName: userName ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Gagal memuat data profil',
      );
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        await _saveImageToLocalStorage(pickedFile);
      }
    } catch (e) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Gagal memilih gambar dari galeri',
      );
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        await _saveImageToLocalStorage(pickedFile);
      }
    } catch (e) {
      // Handle simulator camera not available
      String errorMessage = 'Gagal mengambil foto dari kamera';
      if (e.toString().contains('camera_access_denied')) {
        errorMessage = 'Akses kamera ditolak. Silakan aktifkan di pengaturan.';
      } else if (e.toString().contains('not available') || 
                 e.toString().contains('Camera not available')) {
        errorMessage = 'Kamera tidak tersedia di simulator. Gunakan perangkat fisik atau pilih dari galeri.';
        Info.failed(errorMessage);
      }
      
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: errorMessage,
      );
    }
  }

  // Save image to local storage
  Future<void> _saveImageToLocalStorage(XFile pickedFile) async {
    try {
      // Get application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profileImagesPath = '${appDir.path}/profile_images';
      
      // Create directory if it doesn't exist
      final Directory profileImagesDir = Directory(profileImagesPath);
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Delete old profile image if exists
      final oldImagePath = await UserPreferences.getProfileImagePath();
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      // Generate unique filename
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
      final String newImagePath = '$profileImagesPath/$fileName';

      // Copy file to new location
      final File newFile = await File(pickedFile.path).copy(newImagePath);

      // Save to SharedPreferences
      await UserPreferences.saveProfileImagePath(newFile.path);

      // Update state
      state = state.copyWith(
        statusRequest: StatusRequest.success,
        profileImagePath: newFile.path,
        message: 'Foto profil berhasil diperbarui',
      );
    } catch (e) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Gagal menyimpan foto profil',
      );
    }
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    if (newName.trim().isEmpty) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Nama tidak boleh kosong',
      );
      return;
    }

    try {
      await UserPreferences.saveUserName(newName);
      
      state = state.copyWith(
        statusRequest: StatusRequest.success,
        userName: newName,
        message: 'Nama berhasil diperbarui',
      );
    } catch (e) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Gagal memperbarui nama',
      );
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      await UserPreferences.deleteProfileImage();
      
      state = state.copyWith(
        statusRequest: StatusRequest.success,
        profileImagePath: null,
        message: 'Foto profil berhasil dihapus',
      );
    } catch (e) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: 'Gagal menghapus foto profil',
      );
    }
  }

  static delete() => Get.delete<EditProfileController>(force: true);
}

class EditProfileState {
  final StatusRequest statusRequest;
  final String message;
  final String? profileImagePath;
  final String userName;

  EditProfileState({
    required this.statusRequest,
    required this.message,
    this.profileImagePath,
    required this.userName,
  });

  EditProfileState copyWith({
    StatusRequest? statusRequest,
    String? message,
    String? profileImagePath,
    String? userName,
  }) {
    return EditProfileState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userName: userName ?? this.userName,
    );
  }
}