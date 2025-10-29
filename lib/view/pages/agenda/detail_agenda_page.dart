import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/data/models/agenda_model.dart';
import 'package:kavana_app/view/controllers/detail_agenda/delete_agenda_controller.dart';
import 'package:kavana_app/view/controllers/detail_agenda/detail_agenda_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/response_failed.dart';
import 'package:kavana_app/common/timezones.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String _selectedDisplayTimezone = 'Lokal';
  Map<String, String> _timeZoneDisplayNames = {};
  List<String> _timeZoneOptions = [];

  Future<void> _openMap(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      Info.failed('Koordinat lokasi tidak tersedia.');
      return;
    }
    Uri geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude(Lokasi Agenda)');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      Info.failed('Tidak dapat membuka aplikasi peta.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koordinat: $latitude, $longitude')),
      );
    }
  }

  void delete() async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Hapus Agenda',
      'Apakah Anda yakin ingin menghapus agenda ini?',
      textNo: 'Batal',
      textYes: 'Ya, Hapus',
    );
    if (yes ?? false) {
      final state = await deleteAgendaController.executeRequest(widget.agendaId);
      if (state.statusRequest == StatusRequest.failed) {
        Info.failed(state.message);
        return;
      }
      if (state.statusRequest == StatusRequest.success) {
        Info.success(state.message);
        if (mounted) Navigator.pop(context, 'refresh_agenda');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _timeZoneDisplayNames = getDisplayTimeZoneNames();
    _timeZoneOptions = getDisplayTimeZoneOptions();
    _selectedDisplayTimezone = _timeZoneOptions.first;
    detailAgendaController.fetchData(widget.agendaId);
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

              if (statusRequest == StatusRequest.loading ||
                  statusRequest == StatusRequest.init) {
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
              return RefreshIndicator(
                onRefresh: () async {
                  detailAgendaController.fetchData(widget.agendaId);
                },
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    const Gap(50),
                    buildHeader(agenda.category),
                    const Gap(20),
                    buildTitle(agenda.title),
                    const Gap(30),
                    buildEventDate(agenda.startEvent, agenda.endEvent),
                    const Gap(20),
                    buildTimeZoneSelector(),
                    const Gap(20),
                    if (agenda.locationName != null ||
                        (agenda.latitude != null && agenda.longitude != null))
                      buildLocationInfo(
                          agenda.locationName, agenda.latitude, agenda.longitude),
                    const Gap(30),
                    buildDescription(agenda.description ?? 'Tidak ada deskripsi'),
                    const Gap(30),
                    buildDeleteButton(),
                    const Gap(30),
                  ],
                ),
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
          Chip(
            label: Text(category),
            visualDensity: const VisualDensity(vertical: -4),
            labelStyle: const TextStyle(
              fontSize: 14,
              color: AppColor.primary,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide.none,
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
          fontSize: 18,
          color: AppColor.textTitle,
        ),
      ),
    );
  }

  Widget buildEventDate(DateTime originalStart, DateTime originalEnd) {
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
          Row(
            children: [
              const ImageIcon(
                AssetImage('assets/icons/calendar.png'),
                size: 24,
                color: AppColor.primary,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  formatDateForDisplay(originalStart),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textBody,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 24, color: AppColor.primary),
              const Gap(12),
              Expanded(
                child: Text(
                  formatTimeForDisplay(
                    originalTime: originalStart,
                    displayTimeZoneId: _selectedDisplayTimezone,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textBody,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              const Icon(Icons.timer_off_outlined,
                  size: 24, color: AppColor.primary),
              const Gap(12),
              Expanded(
                child: Text(
                  formatTimeForDisplay(
                    originalTime: originalEnd,
                    displayTimeZoneId: _selectedDisplayTimezone,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textBody,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTimeZoneSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedDisplayTimezone,
        items: _timeZoneOptions.map((id) {
          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              _timeZoneDisplayNames[id] ?? id,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColor.textBody,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedDisplayTimezone = value;
          });
        },
        icon: const Icon(Icons.arrow_drop_down_rounded,
            color: AppColor.primary),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          labelText: 'Tampilkan Waktu dalam Zona',
          labelStyle:
              const TextStyle(color: AppColor.primary, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColor.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColor.primary, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                BorderSide(color: AppColor.primary.withOpacity(0.8), width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildLocationInfo(String? name, double? lat, double? lon) {
    String displayText = name ??
        (lat != null && lon != null
            ? 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}'
            : 'Lokasi Tersimpan');
    bool canOpenMap = lat != null && lon != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              size: 24, color: AppColor.primary),
          const Gap(12),
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textBody,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canOpenMap)
            IconButton(
              icon: const Icon(Icons.map_rounded, color: AppColor.primary),
              onPressed: () => _openMap(lat, lon),
              tooltip: 'Buka di Peta',
              splashRadius: 20,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
        ],
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
            'Deskripsi',
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
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        if (deleteAgendaController.state.statusRequest ==
            StatusRequest.loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColor.error));
        }
        return ButtonDelete(
          onPressed: delete,
          title: 'Hapus Agenda Ini',
        );
      }),
    );
  }
}
