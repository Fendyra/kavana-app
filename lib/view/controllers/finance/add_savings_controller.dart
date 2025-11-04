import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/savings_remote_data_source.dart';
import 'package:kavana_app/data/models/savings_model.dart';
import 'package:intl/intl.dart';

class AddSavingsController extends GetxController {
  final _state = AddSavingsState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;

  AddSavingsState get state => _state.value;
  set state(AddSavingsState n) => _state.value = n;

  Future<AddSavingsState> executeRequest(SavingsModel savings) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (success, message) = await SavingsRemoteDataSource.add(savings);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<AddSavingsController>(force: true);

  Future addSavings(SavingsModel savings) async {}
}

class AddSavingsState {
  final StatusRequest statusRequest;
  final String message;

  AddSavingsState({
    required this.statusRequest,
    required this.message,
  });

  AddSavingsState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return AddSavingsState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}