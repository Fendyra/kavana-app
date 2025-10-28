import 'package:get/get.dart';

import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/agenda_remote_data_source.dart';
import 'package:kavana_app/data/models/agenda_model.dart';

class DetailAgendaController extends GetxController {
  final _state = DetailAgendaState(
    message: '',
    statusRequest: StatusRequest.init,
  ).obs;
  DetailAgendaState get state => _state.value;
  set state(DetailAgendaState n) => _state.value = n;

  Future fetchData(int id) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      agenda,
    ) = await AgendaRemoteDataSource.detail(id);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      agenda: agenda,
    );
  }

  static delete() => Get.delete<DetailAgendaController>(force: true);
}

class DetailAgendaState {
  final StatusRequest statusRequest;
  final String message;
  final AgendaModel? agenda;

  DetailAgendaState({
    required this.statusRequest,
    required this.message,
    this.agenda,
  });

  DetailAgendaState copyWith({
    StatusRequest? statusRequest,
    String? message,
    AgendaModel? agenda,
  }) {
    return DetailAgendaState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      agenda: agenda ?? this.agenda,
    );
  }
}
