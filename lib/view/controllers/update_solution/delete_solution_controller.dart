import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/solution_remote_data_source.dart';

class DeleteSolutionController extends GetxController {
  final _state = DeleteSolutionState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  DeleteSolutionState get state => _state.value;
  set state(DeleteSolutionState n) => _state.value = n;

  Future<DeleteSolutionState> executeRequest(int id) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
    ) = await SolutionRemoteDataSource.delete(id);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<DeleteSolutionController>(force: true);
}

class DeleteSolutionState {
  final StatusRequest statusRequest;
  final String message;

  DeleteSolutionState({
    required this.statusRequest,
    required this.message,
  });

  DeleteSolutionState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return DeleteSolutionState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}
