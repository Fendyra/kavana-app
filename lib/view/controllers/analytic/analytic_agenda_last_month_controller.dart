import 'package:d_chart/d_chart.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/agenda_remote_data_source.dart';

class AnalyticAgendaLastMonthController extends GetxController {
  final _state = AnalyticAgendaLastMonthState(
    message: '',
    statusRequest: StatusRequest.init,
    agendas: [],
  ).obs;
  AnalyticAgendaLastMonthState get state => _state.value;
  set state(AnalyticAgendaLastMonthState n) => _state.value = n;

  Future fetchData(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      agendasRaw,
    ) = await AgendaRemoteDataSource.analytic(userId);

    if (!success) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: message,
      );
      return;
    }

    List<TimeData> agendas = List.from(agendasRaw!).map((e) {
      return TimeData(
        domain: DateTime.parse(e['date']),
        measure: e['total'],
      );
    }).toList();
    state = state.copyWith(
      statusRequest: StatusRequest.success,
      agendas: agendas,
      message: message,
    );
  }

  static delete() => Get.delete<AnalyticAgendaLastMonthController>(force: true);
}

class AnalyticAgendaLastMonthState {
  final StatusRequest statusRequest;
  final String message;
  final List<TimeData> agendas;

  AnalyticAgendaLastMonthState({
    required this.statusRequest,
    required this.message,
    required this.agendas,
  });

  AnalyticAgendaLastMonthState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<TimeData>? agendas,
  }) {
    return AnalyticAgendaLastMonthState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      agendas: agendas ?? this.agendas,
    );
  }
}
