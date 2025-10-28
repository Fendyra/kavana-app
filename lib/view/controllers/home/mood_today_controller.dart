import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/mood_remote_data_source.dart';
import 'package:kavana_app/data/models/mood_model.dart';

class MoodTodayController extends GetxController {
  final _state = MoodTodayState(
    message: '',
    statusRequest: StatusRequest.init,
    list: [],
  ).obs;
  MoodTodayState get state => _state.value;
  set state(MoodTodayState n) => _state.value = n;

  Future fetchData(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      moods,
    ) = await MoodRemoteDataSource.today(userId);

    state = state.copyWith(
      statusRequest: success ? StatusRequest.success : StatusRequest.failed,
      message: message,
      list: moods ?? [],
    );
  }

  static delete() => Get.delete<MoodTodayController>(force: true);
}

class MoodTodayState {
  final StatusRequest statusRequest;
  final String message;
  final List<MoodModel> list;

  MoodTodayState({
    required this.statusRequest,
    required this.message,
    required this.list,
  });

  MoodTodayState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<MoodModel>? list,
  }) {
    return MoodTodayState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      list: list ?? this.list,
    );
  }
}
