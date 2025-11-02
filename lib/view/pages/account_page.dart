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
      'Keluar Akun',
      'Apakah kamu yakin ingin keluar?',
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
            top: 58,
            left: 20,
            right: 0,
            child: buildHeader(),
          ),
          Positioned.fill(
            top: 110,
            child: ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 30),
              children: [
                buildProfile(),
              ],
            ),
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
        String name = user?.name ?? 'Pengguna Kavana';
        String email = user?.email ?? 'pengguna@example.com';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile.png'),
                  fit: BoxFit.cover,
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
                fontSize: 20,
                color: AppColor.textTitle,
              ),
            ),
            const Gap(4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 15,
                color: AppColor.textBody,
              ),
            ),
            const Gap(30),
            buildMoodVisualization(),
            const Gap(24),
            buildSettingsList(),
            const Gap(30),
            SizedBox(
              width: 160,
              child: ButtonSecondary(
                onPressed: logout,
                title: 'Keluar',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildMoodVisualization() {
    final List<Map<String, dynamic>> dailyMoods = [
      {'day': 'Min', 'mood': 'happy', 'value': 4},
      {'day': 'Sen', 'mood': 'neutral', 'value': 2},
      {'day': 'Sel', 'mood': 'sad', 'value': 1},
      {'day': 'Rab', 'mood': 'happy', 'value': 3},
      {'day': 'Kam', 'mood': 'excited', 'value': 5},
      {'day': 'Jum', 'mood': 'neutral', 'value': 2},
      {'day': 'Sab', 'mood': 'happy', 'value': 4},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perjalanan Kavana',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pencapaian Mingguan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColor.textTitle,
                    ),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyMoods.map((mood) {
                      Color barColor;
                      IconData moodIcon;
                      if (mood['mood'] == 'happy') {
                        barColor = Colors.lightGreen;
                        moodIcon = Icons.sentiment_very_satisfied;
                      } else if (mood['mood'] == 'sad') {
                        barColor = Colors.redAccent;
                        moodIcon = Icons.sentiment_very_dissatisfied;
                      } else if (mood['mood'] == 'excited') {
                        barColor = Colors.orangeAccent;
                        moodIcon = Icons.star;
                      } else {
                        barColor = Colors.blueGrey;
                        moodIcon = Icons.sentiment_neutral;
                      }

                      return Column(
                        children: [
                          Icon(moodIcon, color: barColor, size: 24),
                          const Gap(8),
                          Container(
                            height: mood['value'] * 15.0,
                            width: 20,
                            decoration: BoxDecoration(
                              color: barColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            mood['day'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesan & Kesan Pengguna',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColor.textTitle,
                    ),
                  ),
                  Gap(12),
                  Text(
                    'Pesan: Tugasnya memang "segampang itu" dan sepertinya kurang banyak dan menantang, saya dan teman-teman masih bisa nongkrong dan main karena tugasnya cukup dikerjain 2 jam saja selesai.\n\nKesan: Mata Kuliah ini sangat menyenangkan dan santai sekali, dosennya juga asik dan tidak membosankan apalagi pak bagus kalau ngajar di kelas suka ngelawak.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.textBody,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  onTap: () {
                    DInfo.dialogConfirmation(
                      context,
                      'Info',
                      'Fitur notifikasi akan segera hadir!',
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.language_rounded,
                  title: 'Bahasa Aplikasi',
                  onTap: () {
                    DInfo.dialogConfirmation(
                      context,
                      'Info',
                      'Pengaturan bahasa akan segera hadir!',
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan & FAQ',
                  onTap: () {
                    DInfo.dialogConfirmation(
                      context,
                      'Info',
                      'Fitur bantuan akan segera hadir!',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColor.primary, size: 24),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.textTitle,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColor.textBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: AppColor.surface,
      ),
    );
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
          'Akun Saya',
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
