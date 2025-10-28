import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/view/controllers/analytic/analytic_agenda_last_month_controller.dart';
import 'package:kavana_app/view/controllers/analytic/analytic_mood_last_month_controller.dart';
import 'package:kavana_app/view/controllers/analytic/analytic_mood_today_controller.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class AnalyticFragment extends StatefulWidget {
  const AnalyticFragment({super.key});

  @override
  State<AnalyticFragment> createState() => _AnalyticFragmentState();
}

class _AnalyticFragmentState extends State<AnalyticFragment> {
  final analyticMoodTodayController = Get.put(AnalyticMoodTodayController());
  final analyticMoodLastMonthController =
      Get.put(AnalyticMoodLastMonthController());
  final analyticAgendaLastMonthController =
      Get.put(AnalyticAgendaLastMonthController());

  void refresh() {
    Session.getUser().then((value) {
      int userId = value!.id;
      Future.wait([
        analyticMoodTodayController.fetchData(userId),
        analyticMoodLastMonthController.fetchData(userId),
        analyticAgendaLastMonthController.fetchData(userId),
      ]);
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    AnalyticMoodTodayController.delete();
    AnalyticMoodLastMonthController.delete();
    AnalyticAgendaLastMonthController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const Gap(55),
          buildHeader(),
          const Gap(34),
          buildMoodToday(),
          const Gap(34),
          buildMoodLastMonth(),
          const Gap(34),
          buildAgendaLastMonth(),
          const Gap(140),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytic For You',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColor.primary,
          ),
        ),
        Gap(9),
        Text(
          'Check and boost up your quality',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textBody,
          ),
        ),
      ],
    );
  }

  Widget buildMoodToday() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Mood Today',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(30),
          Obx(() {
            final state = analyticMoodTodayController.state;
            final statusRequest = state.statusRequest;
            if (statusRequest == StatusRequest.init) {
              return const SizedBox();
            }
            if (statusRequest == StatusRequest.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (statusRequest == StatusRequest.failed) {
              return ResponseFailed(message: state.message);
            }
            List<TimeData> moods = state.moods;
            List groupsLevel = state.group;
            if (moods.isEmpty) {
              return const ResponseFailed(message: 'No Mood Yet');
            }
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: DChartLineT(
                    groupList: [
                      TimeGroup(
                        id: 'id',
                        data: moods,
                        color: AppColor.primary,
                      ),
                    ],
                    measureAxis: const MeasureAxis(
                      showLine: true,
                      numericViewport: NumericViewport(0, 5),
                      numericTickProvider: NumericTickProvider(
                        desiredTickCount: 6,
                      ),
                    ),
                    layoutMargin: LayoutMargin(10, 0, 0, 10),
                    domainAxis: DomainAxis(
                      minimumPaddingBetweenLabels: 20,
                      labelAnchor: LabelAnchor.after,
                      tickLabelFormatterT: (domain) {
                        return DateFormat('H:mm').format(domain);
                      },
                    ),
                    configRenderLine: ConfigRenderLine(
                      includeArea: true,
                    ),
                  ),
                ),
                const Gap(30),
                GridView(
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 24,
                    mainAxisSpacing: 16,
                  ),
                  children: groupsLevel.map(
                    (e) {
                      int level = e['level'];
                      int total = e['total'];
                      return Row(
                        children: [
                          Image.asset(
                            'assets/images/mood_$level.png',
                            width: 24,
                            height: 24,
                          ),
                          const Gap(12),
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColor.textBody,
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildMoodLastMonth() {
    final now = DateTime.now();
    final startViewport = DateTime(now.year, now.month, 1);
    final lastDay = DateUtils.getDaysInMonth(now.year, now.month);
    final endViewport = DateTime(now.year, now.month, lastDay);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Mood Last Month',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(30),
          Obx(() {
            final state = analyticMoodLastMonthController.state;
            final statusRequest = state.statusRequest;
            if (statusRequest == StatusRequest.init) {
              return const SizedBox();
            }
            if (statusRequest == StatusRequest.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (statusRequest == StatusRequest.failed) {
              return ResponseFailed(message: state.message);
            }
            List<TimeData> moods = state.moods;
            List groupsLevel = state.group;
            if (moods.isEmpty) {
              return const ResponseFailed(message: 'No Mood Yet');
            }
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: DChartLineT(
                    groupList: [
                      TimeGroup(
                        id: 'id',
                        data: moods,
                        color: AppColor.primary,
                      ),
                    ],
                    measureAxis: const MeasureAxis(
                      showLine: true,
                      numericViewport: NumericViewport(0, 5),
                      numericTickProvider: NumericTickProvider(
                        desiredTickCount: 6,
                      ),
                    ),
                    layoutMargin: LayoutMargin(10, 0, 0, 10),
                    domainAxis: DomainAxis(
                      labelAnchor: LabelAnchor.after,
                      tickLabelFormatterT: (domain) {
                        return DateFormat('d').format(domain);
                      },
                      timeViewport: TimeViewport(startViewport, endViewport),
                    ),
                    configRenderLine: ConfigRenderLine(
                      includeArea: true,
                    ),
                  ),
                ),
                const Gap(30),
                GridView(
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 24,
                    mainAxisSpacing: 16,
                  ),
                  children: groupsLevel.map(
                    (e) {
                      int level = e['level'];
                      int total = e['total'];
                      return Row(
                        children: [
                          Image.asset(
                            'assets/images/mood_$level.png',
                            width: 24,
                            height: 24,
                          ),
                          const Gap(12),
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColor.textBody,
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildAgendaLastMonth() {
    final now = DateTime.now();
    final startViewport = DateTime(now.year, now.month, 1);
    final lastDay = DateUtils.getDaysInMonth(now.year, now.month);
    final endViewport = DateTime(now.year, now.month, lastDay);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Agenda Last Month',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(30),
          Obx(() {
            final state = analyticAgendaLastMonthController.state;
            final statusRequest = state.statusRequest;
            if (statusRequest == StatusRequest.init) {
              return const SizedBox();
            }
            if (statusRequest == StatusRequest.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (statusRequest == StatusRequest.failed) {
              return ResponseFailed(message: state.message);
            }
            List<TimeData> agendas = state.agendas;
            if (agendas.isEmpty) {
              return const ResponseFailed(message: 'No Agenda Yet');
            }
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartLineT(
                groupList: [
                  TimeGroup(
                    id: 'id',
                    data: agendas,
                    color: AppColor.primary,
                  ),
                ],
                measureAxis: const MeasureAxis(
                  showLine: true,
                ),
                layoutMargin: LayoutMargin(10, 0, 0, 10),
                domainAxis: DomainAxis(
                  labelAnchor: LabelAnchor.after,
                  tickLabelFormatterT: (domain) {
                    return DateFormat('d').format(domain);
                  },
                  timeViewport: TimeViewport(startViewport, endViewport),
                ),
                configRenderLine: ConfigRenderLine(
                  includeArea: true,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
