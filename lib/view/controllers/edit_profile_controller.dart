import 'dart:io';
import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/datasources/user_remote_data_source.dart';

class EditProfileController extends GetxController {
  final _state = EditProfileState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  
  EditProfileState get state => _state.value;
  set state(EditProfileState n) => _state.value = n;

  Future<EditProfileState> executeRequest({
    required int userId,
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
    File? profilePicture,
  }) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (success, message, user) = await UserRemoteDataSource.updateProfile(
      userId: userId,
      name: name,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      profilePicture: profilePicture,
    );

    if (success && user != null) {
      // Update session dengan data user terbaru
      await Session.saveUser(user.toJson());
    }

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<EditProfileController>(force: true);
}

class EditProfileState {
  final StatusRequest statusRequest;
  final String message;

  EditProfileState({
    required this.statusRequest,
    required this.message,
  });

  EditProfileState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return EditProfileState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}