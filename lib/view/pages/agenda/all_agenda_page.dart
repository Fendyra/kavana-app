import 'dart:math';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/agenda_model.dart';
import 'package:kavana_app/view/controllers/all_agenda/agenda_selected_controller.dart';
import 'package:kavana_app/view/controllers/all_agenda/all_agenda_controller.dart';
import 'package:kavana_app/view/pages/agenda/add_agenda_page.dart';
import 'package:kavana_app/view/pages/agenda/detail_agenda_page.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class AllAgendaPage extends StatefulWidget {
  const AllAgendaPage({super.key});

  static const routeName = '/all-agenda';

  @override
  State<AllAgendaPage> createState() => _AllAgendaPageState();
}

class _AllAgendaPageState extends State<AllAgendaPage> {
  final allAgendaController = Get.put(AllAgendaController());
  final agendaSelectedController = Get.put(AgendaSelectedController());

  refresh() {
    Session.getUser().then((user) {
      int userId = user!.id;
      allAgendaController.fetchData(userId);
    });
  }

  void gotoAddAgenda() {
    Navigator.pushNamed(context, AddAgendaPage.routeName);
  }

  void gotoDetailAgenda(int id) {
    Navigator.pushNamed(
      context,
      DetailAgendaPage.routeName,
      arguments: id,
    ).then(
      (value) {
        if (value == null) return;
        if (value == 'refresh_agenda') {
          agendaSelectedController.reset();
          refresh();
        }
      },
    );
  }

  void selectAgenda(AgendaModel agenda) {
    agendaSelectedController.state = agenda;
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    AllAgendaController.delete();
    AgendaSelectedController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(48),
          buildHeader(),
          const Gap(10),
          buildAgendaSelected(),
          Expanded(
            child: buildWeekView(),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const ImageIcon(
              AssetImage('assets/icons/arrow_back.png'),
              size: 24,
              color: AppColor.primary,
            ),
          ),
          const Text(
            'All Agenda',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.primary,
            ),
          ),
          IconButton(
            onPressed: gotoAddAgenda,
            icon: const ImageIcon(
              AssetImage('assets/icons/add_circle.png'),
              size: 24,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAgendaSelected() {
    return Obx(() {
      final agendaSelected = agendaSelectedController.state;
      int id = agendaSelected.id;
      return GestureDetector(
        onTap: id == 0 ? null : () => gotoDetailAgenda(id),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  agendaSelected.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColor.textTitle,
                  ),
                ),
              ),
              const ImageIcon(
                AssetImage('assets/icons/arrow_right.png'),
                size: 24,
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildWeekView() {
    return Obx(
      () {
        final state = allAgendaController.state;
        final statusRequest = state.statusRequest;
        if (statusRequest == StatusRequest.init) {
          return const SizedBox();
        }
        if (statusRequest == StatusRequest.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (statusRequest == StatusRequest.failed) {
          return ResponseFailed(
            message: state.message,
            margin: const EdgeInsets.all(20),
          );
        }
        final list = state.list;
        if (list.isEmpty) {
          return const ResponseFailed(
            message: 'No Agenda Yet',
            margin: EdgeInsets.all(20),
          );
        }
        return WeekView(
          controller: EventController()..addAll(list),
          weekPageHeaderBuilder: (startDate, endDate) {
            return buildWeekHeader(startDate, endDate);
          },
          eventTileBuilder:
              (date, events, boundary, startDuration, endDuration) {
            return buildEventTile(events.first);
          },
          showLiveTimeLineInAllDays: true,
          width: MediaQuery.sizeOf(context).width,
          minDay: DateTime(2024),
          maxDay: DateTime(DateTime.now().year + 1, DateTime.now().month),
          initialDay: DateTime.now(),
          startDay: WeekDays.sunday,
          showVerticalLines: false,
          backgroundColor: Colors.transparent,
          heightPerMinute: 1,
          eventArranger: const SideEventArranger(),
          keepScrollOffset: true,
          onEventTap: (events, date) {
            selectAgenda(events.first.event as AgendaModel);
          },
          fullDayHeaderTitle: 'Full Day',
        );
      },
    );
  }

  Widget buildWeekHeader(DateTime startDate, DateTime endDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          Text(
            DateFormat('MMM d, yyyy').format(startDate),
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(20),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColor.primary,
              ),
            ),
          ),
          const Gap(20),
          Text(
            DateFormat('MMM d, yyyy').format(endDate),
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEventTile(CalendarEventData event) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [event.startTime, event.endTime].map(
          (e) {
            return Text(
              DateFormat("HH:mm").format(e!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
