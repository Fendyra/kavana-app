import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/solution_remote_data_source.dart';
import 'package:kavana_app/data/models/solution_model.dart';

class DetailSolutionController extends GetxController {
  final _state = DetailSolutionState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  DetailSolutionState get state => _state.value;
  set state(DetailSolutionState n) => _state.value = n;

  Future fetchData(int id) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      solution,
    ) = await SolutionRemoteDataSource.detail(id);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      solution: solution,
    );
  }

  static delete() => Get.delete<DetailSolutionController>(force: true);
}

class DetailSolutionState {
  final StatusRequest statusRequest;
  final String message;
  final SolutionModel? solution;

  DetailSolutionState({
    required this.statusRequest,
    required this.message,
    this.solution,
  });

  DetailSolutionState copyWith({
    StatusRequest? statusRequest,
    String? message,
    SolutionModel? solution,
  }) {
    return DetailSolutionState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      solution: solution ?? this.solution,
    );
  }
}
