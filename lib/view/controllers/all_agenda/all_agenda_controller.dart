import 'package:calendar_view/calendar_view.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/agenda_remote_data_source.dart';

class AllAgendaController extends GetxController {
  final _state = AllAgendaState(
    message: '',
    statusRequest: StatusRequest.init,
    list: [],
  ).obs;
  AllAgendaState get state => _state.value;
  set state(AllAgendaState n) => _state.value = n;

  Future fetchData(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      agendas,
    ) = await AgendaRemoteDataSource.all(userId);

    if (!success) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: message,
      );
      return;
    }

    List<CalendarEventData> list = agendas!.map((e) {
      return CalendarEventData(
        title: e.title,
        date: e.startEvent,
        endDate: e.endEvent,
        startTime: e.startEvent,
        endTime: e.endEvent,
        event: e,
      );
    }).toList();
    state = state.copyWith(
      statusRequest: StatusRequest.success,
      list: list,
      message: message,
    );
  }

  static delete() => Get.delete<AllAgendaController>(force: true);
}

class AllAgendaState {
  final StatusRequest statusRequest;
  final String message;
  final List<CalendarEventData> list;

  AllAgendaState({
    required this.statusRequest,
    required this.message,
    required this.list,
  });

  AllAgendaState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<CalendarEventData>? list,
  }) {
    return AllAgendaState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      list: list ?? this.list,
    );
  }
}
