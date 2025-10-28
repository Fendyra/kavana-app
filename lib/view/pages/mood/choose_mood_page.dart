import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/user_model.dart';
import 'package:kavana_app/view/controllers/choose_mood_controller.dart';
import 'package:kavana_app/view/controllers/home/mood_today_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';

class ChooseMoodPage extends StatefulWidget {
  const ChooseMoodPage({super.key});

  static const routeName = '/choose-mood';

  @override
  State<ChooseMoodPage> createState() => _ChooseMoodPageState();
}

class _ChooseMoodPageState extends State<ChooseMoodPage> {
  final chooseMoodController = Get.put(ChooseMoodController());
  final moodTodayMoodController = Get.put(MoodTodayController());

  UserModel? user;

  void choose() async {
    int userId = user!.id;
    final state = await chooseMoodController.executeRequest(userId);

    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }

    if (state.statusRequest == StatusRequest.success) {
      Info.success(state.message);
      moodTodayMoodController.fetchData(userId);
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }
  }

  @override
  void initState() {
    Session.getUser().then((value) {
      user = value;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    ChooseMoodController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(60),
          buildHeader(),
          const Gap(70),
          buildMoods(),
          const Gap(90),
          buildChooseButton(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const ImageIcon(
                  AssetImage('assets/icons/arrow_back.png'),
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(60),
          Center(
            child: Text(
              '${user?.name ?? ''}, what is your mood\nnow?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColor.textTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoods() {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: PageController(
          initialPage: 2,
          viewportFraction: 0.65,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        onPageChanged: (index) {
          chooseMoodController.level = index + 1;
        },
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String moodAsset = 'assets/images/mood_${index + 1}_big.png';
          return Center(
            child: Transform.rotate(
              angle: pi / -12,
              child: Container(
                width: 212,
                height: 212,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: pi / 12,
                  child: Image.asset(
                    moodAsset,
                    height: 130,
                    width: 130,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildChooseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ButtonPrimary(
          onPressed: choose,
          title: 'Choose',
        ),
      ),
    );
  }
}
