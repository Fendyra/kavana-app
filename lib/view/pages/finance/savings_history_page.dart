import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/savings_model.dart';
import 'package:kavana_app/view/controllers/finance/savings_history_controller.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class SavingsHistoryPage extends StatefulWidget {
  const SavingsHistoryPage({super.key});

  static const routeName = '/savings-history';

  @override
  State<SavingsHistoryPage> createState() => _SavingsHistoryPageState();
}

class _SavingsHistoryPageState extends State<SavingsHistoryPage> {
  final savingsHistoryController = Get.put(SavingsHistoryController());

  void refresh() {
    Session.getUser().then((user) {
      if (user != null) {
        savingsHistoryController.fetchHistory(user.id);
      }
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    SavingsHistoryController.delete();
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
            child: buildList(),
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
            'Savings History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColor.primary,
            ),
          ),
          const IconButton(
            onPressed: null,
            icon: ImageIcon(
              AssetImage('assets/icons/add_circle.png'),
              size: 24,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList() {
    return Obx(() {
      final state = savingsHistoryController.state;
      final statusRequest = state.statusRequest;

      if (statusRequest == StatusRequest.init ||
          statusRequest == StatusRequest.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (statusRequest == StatusRequest.failed) {
        return ResponseFailed(
          message: state.message,
          margin: const EdgeInsets.all(20),
        );
      }

      final savings = state.savings;
      if (savings.isEmpty) {
        return const ResponseFailed(
          message: 'No savings history yet',
          margin: EdgeInsets.all(20),
        );
      }

      // Group by date
      final Map<String, List<SavingsModel>> groupedSavings = {};
      for (var saving in savings) {
        final dateKey = DateFormat('yyyy-MM-dd').format(saving.createdAt);
        if (!groupedSavings.containsKey(dateKey)) {
          groupedSavings[dateKey] = [];
        }
        groupedSavings[dateKey]!.add(saving);
      }

      final sortedKeys = groupedSavings.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final dateKey = sortedKeys[index];
          final savingsOnDate = groupedSavings[dateKey]!;
          final date = DateTime.parse(dateKey);
          final totalOnDate = savingsOnDate.fold<double>(
            0,
            (sum, saving) => sum + saving.amount,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textTitle,
                        ),
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(totalOnDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.success,
                      ),
                    ),
                  ],
                ),
              ),
              ...savingsOnDate.map((saving) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColor.success,
                          size: 24,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(saving.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColor.textBody,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              saving.note.isEmpty
                                  ? 'Daily Savings'
                                  : saving.note,
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
              const Gap(8),
            ],
          );
        },
      );
    });
  }
}