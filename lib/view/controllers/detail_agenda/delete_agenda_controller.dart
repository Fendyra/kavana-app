import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/agenda_remote_data_source.dart';

class DeleteAgendaController extends GetxController {
  final _state = DeleteAgendaState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  DeleteAgendaState get state => _state.value;
  set state(DeleteAgendaState n) => _state.value = n;

  Future<DeleteAgendaState> executeRequest(int id) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
    ) = await AgendaRemoteDataSource.delete(id);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<DeleteAgendaController>(force: true);
}

class DeleteAgendaState {
  final StatusRequest statusRequest;
  final String message;

  DeleteAgendaState({
    required this.statusRequest,
    required this.message,
  });

  DeleteAgendaState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return DeleteAgendaState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}
