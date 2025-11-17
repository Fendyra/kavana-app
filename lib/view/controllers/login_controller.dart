import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/datasources/user_remote_data_source.dart';
import 'package:kavana_app/data/models/user_preferences.dart';

class LoginController extends GetxController {
  final _state = LoginState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  LoginState get state => _state.value;
  set state(LoginState n) => _state.value = n;

  Future<LoginState> executeRequest(
    String email,
    String password,
  ) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      user,
    ) = await UserRemoteDataSource.login(email, password);

    if (success) {
      await Session.saveUser(user!.toJson());
      // Sinkronkan data user ke UserPreferences
      await UserPreferences.saveUserName(user.name);
      await UserPreferences.saveUserEmail(user.email);
      await UserPreferences.saveUserId(user.id);
    }

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<LoginController>(force: true);
}

class LoginState {
  final StatusRequest statusRequest;
  final String message;

  LoginState({
    required this.statusRequest,
    required this.message,
  });

  LoginState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return LoginState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}
