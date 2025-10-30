import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/savings_model.dart';
import 'package:kavana_app/view/controllers/finance/add_savings_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';

class AddSavingsPage extends StatefulWidget {
  const AddSavingsPage({super.key});

  static const routeName = '/add-savings';

  @override
  State<AddSavingsPage> createState() => _AddSavingsPageState();
}

class _AddSavingsPageState extends State<AddSavingsPage> {
  final addSavingsController = Get.put(AddSavingsController());
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final List<int> quickAmounts = [
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
  ];

  void selectQuickAmount(int amount) {
    amountController.text = amount.toString();
  }

  void addSavings() async {
    final amountText = amountController.text.replaceAll('.', '');
    final note = noteController.text;

    if (amountText.isEmpty) {
      Info.failed('Amount must be filled');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Info.failed('Amount must be valid');
      return;
    }

    final user = await Session.getUser();
    if (user == null) return;

    final savings = SavingsModel(
      userId: user.id,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    final state = await addSavingsController.executeRequest(savings);

    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }

    if (state.statusRequest == StatusRequest.success) {
      Info.success(state.message);
      if (mounted) Navigator.pop(context);
      return;
    }
  }

  @override
  void dispose() {
    AddSavingsController.delete();
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(20),
                buildAmountInput(),
                const Gap(24),
                buildQuickAmounts(),
                const Gap(30),
                buildNoteInput(),
                const Gap(40),
                buildAddButton(),
              ],
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
            icon: const ImageIcon(
              AssetImage('assets/icons/arrow_back.png'),
              size: 24,
              color: AppColor.primary,
            ),
          ),
          const Text(
            'Add Savings',
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

  Widget buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: AppColor.primary, width: 2),
          ),
          child: Row(
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColor.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: AppColor.textTitle,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: AppColor.textBody,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildQuickAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Select',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColor.textBody,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return InkWell(
              onTap: () => selectQuickAmount(amount),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColor.secondary.withOpacity(0.3),
                  border: Border.all(color: AppColor.secondary, width: 1),
                ),
                child: Text(
                  'Rp ${amount ~/ 1000}K',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        TextFormField(
          controller: noteController,
          maxLines: 3,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: AppColor.textBody,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Add a note for this savings...',
            isDense: true,
            contentPadding: const EdgeInsets.all(20),
            hintStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: AppColor.textBody,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColor.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColor.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddButton() {
    return Obx(() {
      final state = addSavingsController.state;
      if (state.statusRequest == StatusRequest.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ButtonPrimary(
        onPressed: addSavings,
        title: 'Save',
      );
    });
  }
}