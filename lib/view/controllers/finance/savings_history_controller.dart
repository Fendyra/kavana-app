import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/savings_remote_data_source.dart';
import 'package:kavana_app/data/models/savings_model.dart';

class SavingsHistoryController extends GetxController {
  final _state = SavingsHistoryState(
    message: '',
    statusRequest: StatusRequest.init,
    savings: [],
  ).obs;

  SavingsHistoryState get state => _state.value;
  set state(SavingsHistoryState n) => _state.value = n;

  Future<void> fetchHistory(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (success, message, savings) =
        await SavingsRemoteDataSource.getHistory(userId);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      savings: savings ?? [],
    );
  }

  static delete() => Get.delete<SavingsHistoryController>(force: true);
}

class SavingsHistoryState {
  final StatusRequest statusRequest;
  final String message;
  final List<SavingsModel> savings;

  SavingsHistoryState({
    required this.statusRequest,
    required this.message,
    required this.savings,
  });

  SavingsHistoryState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<SavingsModel>? savings,
  }) {
    return SavingsHistoryState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      savings: savings ?? this.savings,
    );
  }
}