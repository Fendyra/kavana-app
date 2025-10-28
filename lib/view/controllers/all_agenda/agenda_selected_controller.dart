import 'package:get/get.dart';
import 'package:kavana_app/data/models/agenda_model.dart';

class AgendaSelectedController extends GetxController {
  final _state = AgendaModel(
    id: 0,
    title: 'Agenda Selected',
    category: '',
    startEvent: DateTime.now(),
    endEvent: DateTime.now(),
  ).obs;
  AgendaModel get state => _state.value;
  set state(AgendaModel n) => _state.value = n;

  reset() {
    state = AgendaModel(
      id: 0,
      title: 'Agenda Selected',
      category: '',
      startEvent: DateTime.now(),
      endEvent: DateTime.now(),
    );
  }

  static delete() => Get.delete<AgendaSelectedController>(force: true);
}
