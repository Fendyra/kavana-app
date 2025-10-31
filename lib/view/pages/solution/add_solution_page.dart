import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/solution_model.dart';
import 'package:kavana_app/view/controllers/add_solution_controller.dart';
import 'package:kavana_app/view/controllers/solution_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/custom_input.dart';

class AddSolutionPage extends StatefulWidget {
  const AddSolutionPage({super.key});

  static const routeName = '/add-solution';

  @override
  State<AddSolutionPage> createState() => _AddSolutionPageState();
}

class _AddSolutionPageState extends State<AddSolutionPage> {
  final addSolutionController = Get.put(AddSolutionController());
  final findSolutionController = Get.find<SolutionController>();

  final summaryController = TextEditingController();
  final problemController = TextEditingController();
  final solutionController = TextEditingController();
  final referenceController = TextEditingController();

  final references = <String>[].obs;

  void addItemReference() {
    final item = referenceController.text;
    if (item == '') return;
    references.add(item);
    referenceController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void removeItemReference(String item) {
    references.remove(item);
  }

  void addNew() async {
    final summary = summaryController.text;
    final problem = problemController.text;
    final solution = solutionController.text;

    if (summary == '') {
      Info.failed('Ringkasan harus diisi');
      return;
    }
    if (problem == '') {
      Info.failed('Masalah harus diisi');
      return;
    }
    if (solution == '') {
      Info.failed('Solusi harus diisi');
      return;
    }

    final user = await Session.getUser();
    final userId = user!.id;
    final solutionModel = SolutionModel(
      id: 0,
      userId: userId,
      summary: summary,
      problem: problem,
      solution: solution,
      reference: List.from(references),
      createdAt: DateTime.now(),
    );

    final state = await addSolutionController.executeRequest(solutionModel);
    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }
    if (state.statusRequest == StatusRequest.success) {
      Info.success(state.message);
      findSolutionController.fetchData(userId);
      if (mounted) Navigator.pop(context);
      return;
    }
  }

  @override
  void dispose() {
    AddSolutionController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(40),
          buildHeader(),
          const Gap(6),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Gap(6),
                buildSummary(),
                const Gap(20),
                buildProblem(),
                const Gap(20),
                buildSolution(),
                const Gap(20),
                buildReference(),
                const Gap(40),
                buildAddButton(),
                const Gap(30),
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
            'Tambah Solusi',
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

  Widget buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        CustomInput(
          controller: summaryController,
          hint: 'Tulis ringkasan singkat...',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget buildProblem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Masalah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        CustomInput(
          controller: problemController,
          hint: 'Tuliskan permasalahan...',
          maxLines: 1,
        ),
      ],
    );
  }

  Widget buildSolution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solusi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        CustomInput(
          controller: solutionController,
          hint: 'Tuliskan solusi yang kamu temukan...',
          minLines: 2,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget buildReference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Referensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        CustomInput(
          controller: referenceController,
          hint: 'Contoh: Instagram @penulis...',
          maxLines: 1,
          suffixIcon: 'assets/icons/add_circle.png',
          suffixOnTap: addItemReference,
        ),
        const Gap(12),
        Obx(() {
          return Column(
            children: references.map(
              (item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: () => removeItemReference(item),
                          padding: const EdgeInsets.all(0),
                          icon: const ImageIcon(
                            AssetImage('assets/icons/close_circle.png'),
                            size: 24,
                            color: AppColor.error,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, 8),
                          child: SelectableText(
                            item,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColor.textBody,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          );
        }),
      ],
    );
  }

  Widget buildAddButton() {
    return Obx(() {
      if (addSolutionController.state.statusRequest == StatusRequest.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ButtonPrimary(
        onPressed: addNew,
        title: 'Simpan Solusi',
      );
    });
  }
}
