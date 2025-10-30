import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/savings_remote_data_source.dart';
import 'package:kavana_app/data/models/savings_model.dart';

class FinanceController extends GetxController {
  final _state = FinanceState(
    message: '',
    statusRequest: StatusRequest.init,
    totalSavings: 0,
    monthlyTotal: 0,
    savingsDays: 0,
    recentSavings: [],
  ).obs;

  FinanceState get state => _state.value;
  set state(FinanceState n) => _state.value = n;

  Future<void> fetchSavings(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (success, message, data) = 
        await SavingsRemoteDataSource.getSavingsSummary(userId);

    if (!success) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: message,
      );
      return;
    }

    state = state.copyWith(
      statusRequest: StatusRequest.success,
      message: message,
      totalSavings: data!['total_savings'] ?? 0,
      monthlyTotal: data['monthly_total'] ?? 0,
      savingsDays: data['savings_days'] ?? 0,
      recentSavings: data['recent_savings'] ?? [],
    );
  }

  static delete() => Get.delete<FinanceController>(force: true);
}

class FinanceState {
  final StatusRequest statusRequest;
  final String message;
  final double totalSavings;
  final double monthlyTotal;
  final int savingsDays;
  final List<SavingsModel> recentSavings;

  FinanceState({
    required this.statusRequest,
    required this.message,
    required this.totalSavings,
    required this.monthlyTotal,
    required this.savingsDays,
    required this.recentSavings,
  });

  FinanceState copyWith({
    StatusRequest? statusRequest,
    String? message,
    double? totalSavings,
    double? monthlyTotal,
    int? savingsDays,
    List<SavingsModel>? recentSavings,
  }) {
    return FinanceState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      totalSavings: totalSavings ?? this.totalSavings,
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
      savingsDays: savingsDays ?? this.savingsDays,
      recentSavings: recentSavings ?? this.recentSavings,
    );
  }
}