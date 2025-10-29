// File: lib/view/pages/agenda/add_agenda_page.dart
import 'dart:async'; // Import for TimeoutException
import 'package:fd_log/fd_log.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/constants.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/common/logging.dart'; // Ensure fdLog is imported correctly
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/agenda_model.dart';
import 'package:kavana_app/view/controllers/add_agenda_controller.dart';
import 'package:kavana_app/view/controllers/all_agenda/all_agenda_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/custom_input.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator (Ensure it's in dependencies)

// --- Import controller AgendaToday ---
import 'package:kavana_app/view/controllers/home/agenda_today_controller.dart';

class AddAgendaPage extends StatefulWidget {
  const AddAgendaPage({super.key});

  static const routeName = '/add-agenda';

  @override
  State<AddAgendaPage> createState() => _AddAgendaPageState();
}

class _AddAgendaPageState extends State<AddAgendaPage> {
  final addAgendaController = Get.put(AddAgendaController());
  final allAgendaController = Get.isRegistered<AllAgendaController>()
      ? Get.find<AllAgendaController>()
      : Get.put(AllAgendaController());
  // Attempt to find AgendaTodayController, handle if not registered
  final AgendaTodayController? agendaTodayController =
      Get.isRegistered<AgendaTodayController>()
          ? Get.find<AgendaTodayController>()
          : null;

  final titleController = TextEditingController();
  final categoryController = TextEditingController(
    text: Constants.agendaCategories.first,
  );
  final startEventController = TextEditingController(
    text: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
  );
  final endEventController = TextEditingController(
    text: DateFormat('yyyy-MM-dd HH:mm')
        .format(DateTime.now().add(const Duration(hours: 1))),
  );
  final descriptionController = TextEditingController();

  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  void addNew() async {
    final title = titleController.text;
    final category = categoryController.text;
    final startEventStr = startEventController.text;
    final endEventStr = endEventController.text;
    final description = descriptionController.text;

    if (title.isEmpty) {
      Info.failed('Judul harus diisi');
      return;
    }

    DateTime? startEventDate, endEventDate;
    try {
      final format = DateFormat('yyyy-MM-dd HH:mm');
      startEventDate = format.parseStrict(startEventStr);
      endEventDate = format.parseStrict(endEventStr);
    } catch (e) {
      Info.failed('Format tanggal/waktu tidak valid. Gunakan YYYY-MM-DD HH:MM');
      fdLog.error("Date parsing error: $e"); // Corrected fdLog call
      return;
    }

    if (startEventDate.isAfter(endEventDate)) {
      Info.failed('Waktu Selesai harus setelah Waktu Mulai');
      return;
    }
    // Optional: Add minimum duration check if needed
    // if (endEventDate.difference(startEventDate).inMinutes < 30) {
    //   Info.failed('Minimum range event is 30 Minutes');
    //   return;
    // }

    int? userId = (await Session.getUser())?.id;
    if (userId == null) {
      Info.failed('Sesi pengguna tidak ditemukan. Silakan login ulang.');
      return;
    }

    final agenda = AgendaModel(
      id: 0,
      title: title,
      category: category,
      startEvent: startEventDate,
      endEvent: endEventDate,
      description: description.isNotEmpty ? description : null,
      userId: userId,
      locationName: _locationName,
      latitude: _latitude,
      longitude: _longitude,
    );

    final state = await addAgendaController.executeRequest(agenda);

    if (!mounted) return;

    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }

    if (state.statusRequest == StatusRequest.success) {
      allAgendaController.fetchData(userId);

      // Refresh AgendaTodayController if it was found
      if (agendaTodayController != null) {
        agendaTodayController?.fetchData(userId);
      } else {
        fdLog.warning(
            "AgendaTodayController not registered, cannot refresh."); // Corrected fdLog call
      }

      Info.success(state.message);
      Navigator.pop(context);
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Info.failed('Layanan lokasi tidak aktif.');
        if (mounted) await Geolocator.openLocationSettings();
        setState(() => _isGettingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Info.failed('Izin lokasi ditolak.'); // Use failed for consistency
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Info.failed(
            'Izin lokasi ditolak permanen.'); // Use failed for consistency
        if (mounted) await Geolocator.openAppSettings();
        setState(() => _isGettingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15));

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName =
            'Lat: ${_latitude?.toStringAsFixed(4)}, Lon: ${_longitude?.toStringAsFixed(4)}';
        _isGettingLocation = false;
      });
      Info.success('Lokasi saat ini berhasil didapatkan');
    } on TimeoutException {
      Info.failed('Gagal mendapatkan lokasi: Waktu habis.');
      setState(() => _isGettingLocation = false);
    } catch (e) {
      fdLog.error("Error getting location: $e"); // Corrected fdLog call
      Info.failed('Gagal mendapatkan lokasi: ${e.toString()}');
      setState(() => _isGettingLocation = false);
    }
  }

  void chooseDateTime(TextEditingController controller) async {
    DateTime initialDateTime;
    try {
      initialDateTime =
          DateFormat('yyyy-MM-dd HH:mm').parseStrict(controller.text);
    } catch (_) {
      initialDateTime = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) return;

    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    controller.text = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    startEventController.dispose();
    endEventController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(50),
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTitleInput(),
                  const Gap(20),
                  buildCategoryInput(),
                  const Gap(20),
                  buildStartEventInput(),
                  const Gap(20),
                  buildEndEventInput(),
                  const Gap(20),
                  buildLocationInput(),
                  const Gap(20),
                  buildDescriptionInput(),
                  const Gap(30),
                  buildAddButton(),
                  const Gap(20),
                ],
              ),
            ),
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
            icon: const ImageIcon(AssetImage('assets/icons/arrow_back.png'),
                size: 24, color: AppColor.primary),
          ),
          const Text('Tambah Agenda Baru',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColor.primary)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget buildTitleInput() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Judul Agenda',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      CustomInput(
        controller: titleController,
        hint: 'Contoh: Rapat Proyek Akhir',
        maxLines: 1,
        textInputAction: TextInputAction.next,
      ),
    ]);
  }

  Widget buildCategoryInput() {
    if (!Constants.agendaCategories.contains(categoryController.text)) {
      categoryController.text = Constants.agendaCategories.first;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Kategori',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      DropdownButtonFormField<String>(
        value: categoryController.text,
        items: Constants.agendaCategories.map((category) {
          return DropdownMenuItem<String>(
              value: category,
              child: Text(category,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColor.textBody)));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            categoryController.text = value;
          }
        },
        icon: const Icon(Icons.arrow_drop_down_rounded,
            color: AppColor.primary),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColor.primary, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColor.primary, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: AppColor.primary.withOpacity(0.8), width: 2)),
        ),
      ),
    ]);
  }

  Widget buildStartEventInput() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Waktu Mulai',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      CustomInput(
        controller: startEventController,
        hint: 'YYYY-MM-DD HH:MM',
        maxLines: 1,
        readOnly: true,
        onTap: () => chooseDateTime(startEventController),
        suffixIcon: 'assets/icons/calendar.png',
      ),
    ]);
  }

  Widget buildEndEventInput() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Waktu Selesai',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      CustomInput(
        controller: endEventController,
        hint: 'YYYY-MM-DD HH:MM',
        maxLines: 1,
        readOnly: true,
        onTap: () => chooseDateTime(endEventController),
        suffixIcon: 'assets/icons/calendar.png',
      ),
    ]);
  }

  Widget buildLocationInput() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lokasi Acara (Opsional)',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.primary, width: 2)),
        child: Row(children: [
          Icon(Icons.location_on_outlined,
              color: _locationName != null
                  ? AppColor.primary
                  : AppColor.textBody.withOpacity(0.6)),
          const Gap(10),
          Expanded(
              child: Text(
                  _locationName ?? 'Tap ikon lokasi ->',
                  style: TextStyle(
                      fontSize: 14,
                      color: _locationName != null
                          ? AppColor.textBody
                          : AppColor.textBody.withOpacity(0.6),
                      fontStyle: _locationName == null
                          ? FontStyle.italic
                          : FontStyle.normal),
                  overflow: TextOverflow.ellipsis)),
          const Gap(5),
          _isGettingLocation
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColor.primary))
              : IconButton(
                  icon: const Icon(Icons.my_location_rounded,
                      color: AppColor.primary),
                  onPressed: _getCurrentLocation,
                  tooltip: 'Gunakan Lokasi Saat Ini',
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8)),
          if (_locationName != null && !_isGettingLocation)
            IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: AppColor.error.withOpacity(0.8)),
                onPressed: () {
                  setState(() {
                    _locationName = null;
                    _latitude = null;
                    _longitude = null;
                  });
                },
                tooltip: 'Hapus Lokasi',
                splashRadius: 20,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8)),
        ]),
      ),
    ]);
  }

  Widget buildDescriptionInput() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Deskripsi (Opsional)',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.textTitle)),
      const Gap(12),
      CustomInput(
        controller: descriptionController,
        hint: 'Catatan tambahan...',
        minLines: 3,
        maxLines: 6,
        textInputAction: TextInputAction.done,
      ),
    ]);
  }

  Widget buildAddButton() {
    return Obx(() {
      final statusRequest = addAgendaController.state.statusRequest;
      return SizedBox(
        width: double.infinity,
        child: ButtonPrimary(
          onPressed: statusRequest == StatusRequest.loading ? null : addNew,
          title: statusRequest == StatusRequest.loading
              ? 'Menyimpan...'
              : 'Simpan Agenda',
        ),
      );
    });
  }
}

extension on FDLog {
  void error(String s) {}
  
  void warning(String s) {}
}