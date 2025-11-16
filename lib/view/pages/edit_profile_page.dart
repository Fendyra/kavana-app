import 'dart:io';
import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/user_preferences.dart';
import 'package:kavana_app/view/controllers/edit_profile_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/input_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const routeName = '/edit-profile';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final editProfileController = Get.put(EditProfileController());
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = await Session.getUser();
    if (user != null) {
      // Load name from SharedPreferences first, fallback to session
      final savedName = await UserPreferences.getUserName();
      nameController.text = savedName ?? user.name;
      
      // Save to SharedPreferences if not exists
      if (savedName == null) {
        await UserPreferences.saveUserName(user.name);
        await UserPreferences.saveUserEmail(user.email);
        await UserPreferences.saveUserId(user.id);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(20),
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textTitle,
                  ),
                ),
                const Gap(20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColor.primary,
                  ),
                  title: const Text('Ambil Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    editProfileController.pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColor.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    editProfileController.pickImageFromGallery();
                  },
                ),
                if (editProfileController.state.profileImagePath != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_rounded,
                      color: AppColor.error,
                    ),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(color: AppColor.error),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await DInfo.dialogConfirmation(
                        context,
                        'Hapus Foto Profil',
                        'Apakah Anda yakin ingin menghapus foto profil?',
                      );
                      if (confirm ?? false) {
                        editProfileController.deleteProfileImage();
                      }
                    },
                  ),
                const Gap(20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveChanges() async {
    final newName = nameController.text.trim();
    
    if (newName.isEmpty) {
      Info.failed('Nama tidak boleh kosong');
      return;
    }

    await editProfileController.updateUserName(newName);
    
    if (editProfileController.state.statusRequest == StatusRequest.success) {
      Info.success('Profil berhasil diperbarui');
      if (mounted) Navigator.pop(context, true);
    } else {
      Info.failed(editProfileController.state.message);
    }
  }

  @override
  void dispose() {
    EditProfileController.delete();
    nameController.dispose();
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
            child: Obx(() {
              final state = editProfileController.state;
              if (state.statusRequest == StatusRequest.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Gap(20),
                  buildProfileImage(),
                  const Gap(40),
                  buildNameInput(),
                  const Gap(40),
                  buildSaveButton(),
                ],
              );
            }),
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
            'Edit Profil',
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

  Widget buildProfileImage() {
    return Obx(() {
      final imagePath = editProfileController.state.profileImagePath;
      
      return Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 4, color: AppColor.primary),
                image: imagePath != null && File(imagePath).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage('assets/images/profile.png'),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: AppColor.primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        InputAuth(
          controller: nameController,
          hint: 'Masukkan nama Anda',
          icon: 'assets/icons/profile_square.png',
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return ButtonPrimary(
      onPressed: _saveChanges,
      title: 'Simpan Perubahan',
    );
  }
}