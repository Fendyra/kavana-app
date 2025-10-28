import 'package:d_chart/d_chart.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/data/datasources/mood_remote_data_source.dart';

class AnalyticMoodLastMonthController extends GetxController {
  final _state = AnalyticMoodLastMonthState(
    message: '',
    statusRequest: StatusRequest.init,
    moods: [],
    group: [],
  ).obs;
  AnalyticMoodLastMonthState get state => _state.value;
  set state(AnalyticMoodLastMonthState n) => _state.value = n;

  Future fetchData(int userId) async {
    state = state.copyWith(
      statusRequest: StatusRequest.loading,
    );

    final (
      success,
      message,
      data,
    ) = await MoodRemoteDataSource.analyticLastMonth(userId);

    if (!success) {
      state = state.copyWith(
        statusRequest: StatusRequest.failed,
        message: message,
      );
      return;
    }

    List<TimeData> moods = List.from(data!['moods']).map((e) {
      return TimeData(
        domain: DateTime.parse(e['created_at']),
        measure: e['level'],
      );
    }).toList();
    state = state.copyWith(
      statusRequest: StatusRequest.success,
      moods: moods,
      group: data['group'],
      message: message,
    );
  }

  static delete() => Get.delete<AnalyticMoodLastMonthController>(force: true);
}

class AnalyticMoodLastMonthState {
  final StatusRequest statusRequest;
  final String message;
  final List<TimeData> moods;
  final List group;

  AnalyticMoodLastMonthState({
    required this.statusRequest,
    required this.message,
    required this.moods,
    required this.group,
  });

  AnalyticMoodLastMonthState copyWith({
    StatusRequest? statusRequest,
    String? message,
    List<TimeData>? moods,
    List? group,
  }) {
    return AnalyticMoodLastMonthState(
      statusRequest: statusRequest ?? this.statusRequest,
      message: message ?? this.message,
      moods: moods ?? this.moods,
      group: group ?? this.group,
    );
  }
}
