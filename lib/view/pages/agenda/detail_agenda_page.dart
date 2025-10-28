import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/data/models/agenda_model.dart';
import 'package:kavana_app/view/controllers/detail_agenda/delete_agenda_controller.dart';
import 'package:kavana_app/view/controllers/detail_agenda/detail_agenda_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class DetailAgendaPage extends StatefulWidget {
  const DetailAgendaPage({super.key, required this.agendaId});
  final int agendaId;

  static const routeName = '/detail-agenda';

  @override
  State<DetailAgendaPage> createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends State<DetailAgendaPage> {
  final detailAgendaController = Get.put(DetailAgendaController());
  final deleteAgendaController = Get.put(DeleteAgendaController());

  void delete() async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Delete',
      'Click yes to confirm delete',
    );
    if (yes ?? false) {
      final state =
          await deleteAgendaController.executeRequest(widget.agendaId);

      if (state.statusRequest == StatusRequest.failed) {
        Info.failed(state.message);
        return;
      }

      if (state.statusRequest == StatusRequest.success) {
        Info.success(state.message);
        if (mounted) Navigator.pop(context, 'refresh_agenda');
        return;
      }
    }
  }

  @override
  void initState() {
    detailAgendaController.fetchData(widget.agendaId);
    super.initState();
  }

  @override
  void dispose() {
    DetailAgendaController.delete();
    DeleteAgendaController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Obx(
            () {
              final state = detailAgendaController.state;
              final statusRequest = state.statusRequest;
              if (statusRequest == StatusRequest.init) {
                return const SizedBox();
              }
              if (statusRequest == StatusRequest.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (statusRequest == StatusRequest.failed) {
                return Center(
                  child: ResponseFailed(
                    message: state.message,
                    margin: const EdgeInsets.all(20),
                  ),
                );
              }
              AgendaModel agenda = state.agenda!;
              return ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  const Gap(50),
                  buildHeader(agenda.category),
                  const Gap(20),
                  buildTitle(agenda.title),
                  const Gap(30),
                  buildEventDate(agenda.startEvent, agenda.endEvent),
                  const Gap(30),
                  buildDescription(agenda.description ?? '-'),
                  const Gap(30),
                  buildDeleteButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildHeader(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const ImageIcon(
              AssetImage('assets/icons/arrow_back.png'),
              size: 24,
              color: Colors.white,
            ),
          ),
          const Gap(10),
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColor.textTitle,
        ),
      ),
    );
  }

  Widget buildEventDate(DateTime start, DateTime end) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [start, '', end].map(
          (e) {
            if (e == '') return const Gap(12);
            return Row(
              children: [
                const ImageIcon(
                  AssetImage('assets/icons/calendar.png'),
                  size: 24,
                  color: AppColor.primary,
                ),
                const Gap(12),
                Text(
                  DateFormat('EEEE, dd/MM/yyyy, HH:mm').format(e as DateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textBody,
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildDescription(String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ButtonDelete(
        onPressed: delete,
        title: 'Delete',
      ),
    );
  }
}
