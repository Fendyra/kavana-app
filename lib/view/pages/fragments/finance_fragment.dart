import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/view/controllers/finance/finance_controller.dart';
import 'package:kavana_app/view/pages/finance/add_savings_page.dart';
import 'package:kavana_app/view/pages/finance/currency_converter_page.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class FinanceFragment extends StatefulWidget {
  const FinanceFragment({super.key});

  @override
  State<FinanceFragment> createState() => _FinanceFragmentState();
}

class _FinanceFragmentState extends State<FinanceFragment> {
  final financeController = Get.put(FinanceController());

  void refresh() {
    Session.getUser().then((user) {
      if (user != null) {
        financeController.fetchSavings(user.id);
      }
    });
  }

  void gotoAddSavings() {
    Navigator.pushNamed(context, AddSavingsPage.routeName).then((_) {
      refresh();
    });
  }

  void gotoCurrencyConverter() {
    Navigator.pushNamed(
      context,
      CurrencyConverterPage.routeName,
      arguments: financeController.state.totalSavings,
    );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    FinanceController.delete();
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
          buildSavingsCard(),
          const Gap(34),
          buildTodayQuestion(),
          const Gap(34),
          buildSavingsStats(),
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
          'Finance Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColor.primary,
          ),
        ),
        Gap(9),
        Text(
          'Manage your savings wisely',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textBody,
          ),
        ),
      ],
    );
  }

  Widget buildSavingsCard() {
    return Obx(() {
      final state = financeController.state;
      final statusRequest = state.statusRequest;

      if (statusRequest == StatusRequest.init ||
          statusRequest == StatusRequest.loading) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [AppColor.primary, AppColor.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      final totalSavings = state.totalSavings;
      final formattedAmount = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(totalSavings);

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [AppColor.primary, AppColor.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 20,
              color: AppColor.primary.withOpacity(0.3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Savings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Material(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: gotoCurrencyConverter,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'IDR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(4),
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              formattedAmount,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: _buildSavingsInfo(
                    icon: Icons.trending_up,
                    label: 'This Month',
                    value:
                        'Rp ${NumberFormat('#,###', 'id_ID').format(state.monthlyTotal)}',
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: _buildSavingsInfo(
                    icon: Icons.calendar_today,
                    label: 'Total Days',
                    value: '${state.savingsDays} days',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSavingsInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const Gap(6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTodayQuestion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 10,
            color: AppColor.primary.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('💰', style: TextStyle(fontSize: 48)),
          const Gap(16),
          const Text(
            'Are you going to save today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(16),
          const Text(
            'Saving regularly helps you achieve your financial goals faster.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textBody,
            ),
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gotoAddSavings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Yes, Add Savings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSavingsStats() {
    return Obx(() {
      final state = financeController.state;
      final statusRequest = state.statusRequest;

      if (statusRequest == StatusRequest.failed) {
        return ResponseFailed(message: state.message);
      }

      if (state.recentSavings.isEmpty &&
          statusRequest == StatusRequest.success) {
        return const ResponseFailed(message: 'No recent savings');
      }

      if (state.recentSavings.isEmpty) {
        return const SizedBox();
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Savings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColor.textTitle,
              ),
            ),
            const Gap(16),
            ...state.recentSavings.take(5).map((saving) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColor.success,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMM yyyy')
                                .format(saving.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.textBody,
                            ),
                          ),
                          Text(
                            saving.note.isEmpty ? 'Savings' : saving.note,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.textTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(saving.amount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
