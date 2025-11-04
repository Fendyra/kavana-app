import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/core/api.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/user_model.dart';
import 'package:kavana_app/view/controllers/edit_profile_controller.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/custom_input.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const routeName = '/edit-profile';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final editProfileController = Get.put(EditProfileController());
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  File? _imageFile;
  UserModel? user;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    user = await Session.getUser();
    if (user != null) {
      nameController.text = user!.name;
      emailController.text = user!.email;
    }
    setState(() {});
  }

  void _pickImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    setState(() {
      _isLoadingImage = false;
    });

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() async {
    if (user == null) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validasi
    if (name.isEmpty) {
      Info.failed('Nama harus diisi');
      return;
    }

    if (email.isEmpty) {
      Info.failed('Email harus diisi');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Info.failed('Email tidak valid');
      return;
    }

    // Validasi password jika ingin mengganti
    if (newPassword.isNotEmpty) {
      if (currentPassword.isEmpty) {
        Info.failed('Password lama harus diisi');
        return;
      }

      if (newPassword.length < 6) {
        Info.failed('Password baru minimal 6 karakter');
        return;
      }

      if (newPassword != confirmPassword) {
        Info.failed('Konfirmasi password tidak sesuai');
        return;
      }
    }

    final state = await editProfileController.executeRequest(
      userId: user!.id,
      name: name != user!.name ? name : null,
      email: email != user!.email ? email : null,
      currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
      profilePicture: _imageFile,
    );

    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }

    if (state.statusRequest == StatusRequest.success) {
      Info.success(state.message);
      if (mounted) {
        Navigator.pop(context, 'refresh');
      }
      return;
    }
  }

  @override
  void dispose() {
    EditProfileController.delete();
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
                buildProfilePicture(),
                const Gap(30),
                buildNameInput(),
                const Gap(20),
                buildEmailInput(),
                const Gap(30),
                const Text(
                  'Ubah Password (Opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColor.textTitle,
                  ),
                ),
                const Gap(12),
                buildCurrentPasswordInput(),
                const Gap(20),
                buildNewPasswordInput(),
                const Gap(20),
                buildConfirmPasswordInput(),
                const Gap(40),
                buildSaveButton(),
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

  Widget buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 4, color: AppColor.primary),
              image: DecorationImage(
                image: _getImageProvider(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isLoadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Material(
              color: AppColor.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: _isLoadingImage ? null : _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
      return NetworkImage('${API.baseURL}/${user!.profilePicture}');
    } else {
      return const AssetImage('assets/images/profile.png');
    }
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
        CustomInput(
          controller: nameController,
          hint: 'Masukkan nama Anda',
          maxLines: 1,
        ),
      ],
    );
  }

  Widget buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColor.textTitle,
          ),
        ),
        const Gap(12),
        CustomInput(
          controller: emailController,
          hint: 'Masukkan email Anda',
          maxLines: 1,
        ),
      ],
    );
  }

  Widget buildCurrentPasswordInput() {
    return CustomInput(
      controller: currentPasswordController,
      hint: 'Password lama',
      maxLines: 1,
    );
  }

  Widget buildNewPasswordInput() {
    return CustomInput(
      controller: newPasswordController,
      hint: 'Password baru (minimal 6 karakter)',
      maxLines: 1,
    );
  }

  Widget buildConfirmPasswordInput() {
    return CustomInput(
      controller: confirmPasswordController,
      hint: 'Konfirmasi password baru',
      maxLines: 1,
    );
  }

  Widget buildSaveButton() {
    return Obx(() {
      final state = editProfileController.state;
      if (state.statusRequest == StatusRequest.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ButtonPrimary(
        onPressed: _saveChanges,
        title: 'Simpan Perubahan',
      );
    });
  }
}