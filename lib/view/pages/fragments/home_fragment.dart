import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/agenda_model.dart';
import 'package:kavana_app/data/models/mood_model.dart';
import 'package:kavana_app/view/controllers/home/agenda_today_controller.dart';
import 'package:kavana_app/view/controllers/home/mood_today_controller.dart';
import 'package:kavana_app/view/controllers/profile_controller.dart';
import 'package:kavana_app/view/pages/account_page.dart';
import 'package:kavana_app/view/pages/agenda/all_agenda_page.dart';
import 'package:kavana_app/view/pages/agenda/detail_agenda_page.dart';
import 'package:kavana_app/view/pages/chat_ai_page.dart';
import 'package:kavana_app/view/pages/mood/choose_mood_page.dart';
import 'package:kavana_app/view/pages/pet/pet_page.dart';
import 'package:kavana_app/view/widget/response_failed.dart';
import 'package:kavana_app/view/widget/pet_mini_widget.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final moodTodayController = Get.put(MoodTodayController());
  final agendaTodayController = Get.put(AgendaTodayController());
  final profileController = Get.put(ProfileController());

  refresh() async {
    final user = await Session.getUser();
    int userId = user!.id;
    moodTodayController.fetchData(userId);
    agendaTodayController.fetchData(userId);
    profileController.loadProfileData();
  }

  refreshAgenda() {
    Session.getUser().then((user) {
      int userId = user!.id;
      agendaTodayController.fetchData(userId);
    });
  }

  void gotoAccount() {
    Navigator.pushNamed(context, AccountPage.routeName);
  }

  void gotoChatAI() {
    Navigator.pushNamed(context, ChatAIPage.routeName);
  }

  void gotoChooseMood() {
    Navigator.pushNamed(context, ChooseMoodPage.routeName);
  }

  void gotoAllAgenda() {
    Navigator.pushNamed(context, AllAgendaPage.routeName);
  }

  void gotoPetPage() {
    Navigator.pushNamed(context, PetPage.routeName).then((_) => refresh());
  }

  void gotoDetailAgenda(int id) {
    Navigator.pushNamed(
      context,
      DetailAgendaPage.routeName,
      arguments: id,
    ).then(
      (value) {
        if (value == null) return;
        if (value == 'refresh_agenda') refreshAgenda();
      },
    );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    MoodTodayController.delete();
    AgendaTodayController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => refresh(),
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildHeader(),
          const Gap(36),
          buildYourMoodToday(),
          const Gap(36),
          PetMiniWidget(onTap: gotoPetPage),
          const Gap(36),
          buildYourAgendaToday(),
          const Gap(140),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: AppColor.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(55),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildProfile(),
              IconButton.filled(
                onPressed: gotoChatAI,
                constraints: BoxConstraints.tight(const Size(48, 48)),
                color: AppColor.primary,
                style: const ButtonStyle(
                  overlayColor: WidgetStatePropertyAll(AppColor.secondary),
                ),
                icon: const ImageIcon(
                  AssetImage('assets/icons/message.png'),
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Gap(26),
          const Text(
            'Mood Harian',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: AppColor.textBody,
            ),
          ),
          const Gap(6),
          buildTitle(),
          const Gap(16),
          buildButtonYourMood(),
          const Gap(20),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return Row(
      children: [
        GestureDetector(
          onTap: gotoAccount,
          child: profileController.getProfileImage(size: 48),
        ),
        const Gap(16),
        Obx(() {
          return Text(
            'Hi, ${profileController.userName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColor.textTitle,
            ),
          );
        }),
      ],
    );
  }

  Widget buildTitle() {
    return RichText(
      text: const TextSpan(
        text: 'Bagaimana Perasaan\nAnda Tentang ',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 26,
          color: AppColor.textTitle,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: 'Perasaan\nSaat Ini?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonYourMood() {
    return Material(
      color: AppColor.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: gotoChooseMood,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perasaanmu..',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              ImageIcon(
                AssetImage('assets/icons/arrow_right.png'),
                size: 24,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildYourMoodToday() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Perasaanmu Hari Ini',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColor.textTitle,
            ),
          ),
        ),
        const Gap(24),
        Obx(() {
          final state = moodTodayController.state;
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
            );
          }
          final list = state.list;
          if (list.isEmpty) {
            return const ResponseFailed(
              message: 'Belum Ada Suasana Hati Hari Ini',
              margin: const EdgeInsets.symmetric(horizontal: 20),
            );
          }
          return SizedBox(
            height: 90,
            child: ListView.builder(
              itemCount: list.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                MoodModel mood = list[index];
                return buildMoodItem(mood);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget buildMoodItem(MoodModel mood) {
    String moodAsset = 'assets/images/mood_${mood.level}.png';
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        moodAsset,
        height: 60,
        width: 60,
      ),
    );
  }

  Widget buildYourAgendaToday() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agenda Hari Ini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColor.textTitle,
                ),
              ),
              InkWell(
                onTap: gotoAllAgenda,
                child: const Text(
                  'Semua Agenda',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(24),
        Obx(() {
          final state = agendaTodayController.state;
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
            );
          }
          final list = state.list;
          if (list.isEmpty) {
            return const ResponseFailed(
              message: 'Belum Ada Agenda Hari Ini',
              margin: const EdgeInsets.symmetric(horizontal: 20),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              AgendaModel agenda = list[index];
              return buildAgendaItem(agenda);
            },
          );
        }),
      ],
    );
  }

  Widget buildAgendaItem(AgendaModel agenda) {
    return GestureDetector(
      onTap: () => gotoDetailAgenda(agenda.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agenda.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColor.textTitle,
              ),
            ),
            const Gap(16),
            Row(
              children: [
                Chip(
                  label: Text(
                    DateFormat('H:mm').format(agenda.startEvent),
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColor.textTitle,
                  ),
                  backgroundColor: AppColor.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColor.secondary, width: 1),
                  ),
                ),
                const Gap(10),
                Chip(
                  label: Text(agenda.category),
                  visualDensity: const VisualDensity(vertical: -4),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: AppColor.textTitle,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColor.secondary, width: 1),
                  ),
                ),
                const Spacer(),
                const ImageIcon(
                  AssetImage('assets/icons/arrow_right.png'),
                  size: 24,
                  color: AppColor.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}