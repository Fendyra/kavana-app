import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/solution_remote_data_source.dart';
import 'package:kavana_app/data/models/solution_model.dart';

class SolutionController extends GetxController {
  final _state = SolutionState(
    message: '',
    statusRequest: StatusRequest.init,
    list: [],
  ).obs;
  SolutionState get state => _state.value;
  set state(SolutionState n) => _state.value = n;

  Future fetchData(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      solutions,
    ) = await SolutionRemoteDataSource.all(userId);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      list: solutions ?? [],
    );
  }

  Future search(int userId, String query) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      solutions,
    ) = await SolutionRemoteDataSource.search(userId, query);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      list: solutions ?? [],
    );
  }

  static delete() => Get.delete<SolutionController>(force: true);
}

class SolutionState {
  final StatusRequest statusRequest;
  final String message;
  final List<SolutionModel> list;

  SolutionState({
    required this.statusRequest,
    required this.message,
    required this.list,
  });

  SolutionState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<SolutionModel>? list,
  }) {
    return SolutionState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      list: list ?? this.list,
    );
  }
}
