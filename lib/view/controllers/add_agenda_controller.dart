import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/agenda_remote_data_source.dart';
import 'package:kavana_app/data/models/agenda_model.dart';

class AddAgendaController extends GetxController {
  final _state = AddAgendaState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  AddAgendaState get state => _state.value;
  set state(AddAgendaState n) => _state.value = n;

  Future<AddAgendaState> executeRequest(AgendaModel agenda) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
    ) = await AgendaRemoteDataSource.add(agenda);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
    );

    return state;
  }

  static delete() => Get.delete<AddAgendaController>(force: true);
}

class AddAgendaState {
  final StatusRequest statusRequest;
  final String message;

  AddAgendaState({
    required this.statusRequest,
    required this.message,
  });

  AddAgendaState copyWith({
    StatusRequest? statusRequest,
    String? message,
  }) {
    return AddAgendaState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
    );
  }
}
