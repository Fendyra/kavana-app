import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/solution_model.dart';
import 'package:kavana_app/view/controllers/solution_controller.dart';
import 'package:kavana_app/view/pages/solution/add_solution_page.dart';
import 'package:kavana_app/view/pages/solution/detail_solution_page.dart';
import 'package:kavana_app/view/pages/solution/update_solution_page.dart';
import 'package:kavana_app/view/widget/response_failed.dart';

class SolutionFragment extends StatefulWidget {
  const SolutionFragment({super.key});

  @override
  State<SolutionFragment> createState() => _SolutionFragmentState();
}

class _SolutionFragmentState extends State<SolutionFragment> {
  final solutionController = Get.put(SolutionController());
  final searchController = TextEditingController();

  void gotoAddSolution() {
    Navigator.pushNamed(context, AddSolutionPage.routeName);
  }

  void gotoDetailSolution(int id) {
    Navigator.pushNamed(
      context,
      DetailSolutionPage.routeName,
      arguments: id,
    );
  }

  void gotoUpdateSolution(SolutionModel solution) {
    Navigator.pushNamed(
      context,
      UpdateSolutionPage.routeName,
      arguments: solution,
    );
  }

  void search() {
    final query = searchController.text;
    if (query == '') return;

    Session.getUser().then((user) {
      int userId = user!.id;
      solutionController.search(userId, query);
    });
  }

  refresh() {
    Session.getUser().then((user) {
      int userId = user!.id;
      solutionController.fetchData(userId);
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    SolutionController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(55),
        buildHeader(),
        const Gap(30),
        buildSearchBox(),
        const Gap(16),
        Expanded(
          child: buildList(),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'solusi pikiranmu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColor.primary,
                  ),
                ),
                Gap(9),
                Text(
                  'Temukan dan atasi tantanganmu dengan cara positif',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.textBody,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              onPressed: gotoAddSolution,
              heroTag: 'add-solution-btn',
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const ImageIcon(
                AssetImage('assets/icons/doc_add_outlined.png'),
                size: 24,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: searchController,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.white,
        ),
        autocorrect: false,
        enableSuggestions: false,
        cursorColor: AppColor.secondary,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: search,
            child: const UnconstrainedBox(
              alignment: Alignment(-0.5, 0),
              child: ImageIcon(
                AssetImage('assets/icons/search.png'),
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          hintText: 'Cari solusi untuk masalahmu...',
          hintStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: Colors.white,
          ),
          fillColor: AppColor.primary,
          filled: true,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildList() {
    return Obx(
      () {
        final state = solutionController.state;
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
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 140),
          );
        }
        final list = state.list;
        if (list.isEmpty) {
          return const ResponseFailed(
            message: 'Belum ada solusi tersimpan',
            margin: EdgeInsets.fromLTRB(20, 16, 20, 140),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
          itemBuilder: (context, index) {
            SolutionModel solution = list[index];
            return buildItemList(solution);
          },
        );
      },
    );
  }

  Widget buildItemList(SolutionModel solution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => gotoDetailSolution(solution.id),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 55),
                    child: Text(
                      solution.problem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColor.textTitle,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    solution.solution,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColor.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              width: 46,
              height: 36,
              child: FloatingActionButton(
                onPressed: () => gotoUpdateSolution(solution),
                heroTag: 'solution-${solution.id}',
                backgroundColor: AppColor.primary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: const ImageIcon(
                  AssetImage('assets/icons/edit.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
