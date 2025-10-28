import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/view/widget/bottom_clip_painter.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/top_clip_painter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  static const routeName = '/account';

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void logout() async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Logout',
      'Yes to confirm',
    );
    if (yes ?? false) {
      Session.removeUser();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => route.settings.name == '/dashboard',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: TopClipPainter(),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: BottomClipPainter(),
          ),
          Positioned(
            top: 210,
            left: 0,
            right: 0,
            child: buildProfile(),
          ),
          Positioned(
            top: 58,
            left: 20,
            right: 0,
            child: buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return FutureBuilder(
        future: Session.getUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          String name = user?.name ?? '';
          String email = user?.email ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile.png'),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(width: 4, color: AppColor.primary),
                ),
              ),
              const Gap(16),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColor.textTitle,
                ),
              ),
              const Gap(4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textBody,
                ),
              ),
              const Gap(40),
              SizedBox(
                width: 140,
                child: ButtonSecondary(
                  onPressed: logout,
                  title: 'Logout',
                ),
              ),
            ],
          );
        });
  }

  Widget buildHeader() {
    return Row(
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
        const Gap(16),
        const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.primary,
          ),
        ),
      ],
    );
  }
}
