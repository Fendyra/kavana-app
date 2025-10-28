import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/common/enums.dart';
import 'package:kavana_app/common/info.dart';
import 'package:kavana_app/view/controllers/register_controller.dart';
import 'package:kavana_app/view/pages/login_page.dart';
import 'package:kavana_app/view/widget/custom_button.dart';
import 'package:kavana_app/view/widget/input_auth.dart';
import 'package:kavana_app/view/widget/top_clip_painter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerController = Get.put(RegisterController());
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void gotoLogin() {
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  void register() async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    if (name == '') {
      Info.failed('Name must be filled');
      return;
    }

    if (email == '') {
      Info.failed('Email must be filled');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Info.failed('Email not valid');
      return;
    }

    if (password == '') {
      Info.failed('Password must be filled');
      return;
    }

    if (password.length < 6) {
      Info.failed('Password minimum 6 character');
      return;
    }

    final state = await registerController.executeRequest(
      name,
      email,
      password,
    );

    if (state.statusRequest == StatusRequest.failed) {
      Info.failed(state.message);
      return;
    }

    if (state.statusRequest == StatusRequest.success) {
      Info.success(state.message);
      return;
    }
  }

  @override
  void dispose() {
    RegisterController.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      buildHeader(),
                      const Gap(40),
                      buildInput(),
                    ],
                  ),
                  buildLoginNavigation(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildHeader() {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: TopClipPainter(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(MediaQuery.paddingOf(context).top),
            Image.asset(
              'assets/images/logo_auth.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            const Gap(45),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColor.primary,
                    ),
                  ),
                  Gap(10),
                  Text(
                    'Please enter your data to register',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.textBody,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          InputAuth(
            controller: nameController,
            hint: 'Name',
            icon: 'assets/icons/profile_square.png',
          ),
          const Gap(24),
          InputAuth(
            controller: emailController,
            hint: 'Email',
            icon: 'assets/icons/email.png',
          ),
          const Gap(24),
          InputAuth(
            controller: passwordController,
            hint: 'Password',
            obscureText: true,
            icon: 'assets/icons/lock.png',
          ),
          const Gap(32),
          Obx(() {
            final state = registerController.state;
            if (state.statusRequest == StatusRequest.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              width: double.infinity,
              child: ButtonPrimary(
                onPressed: register,
                title: 'Register',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildLoginNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account?',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColor.textTitle,
            ),
          ),
          const Gap(4),
          InkWell(
            onTap: gotoLogin,
            child: const Text(
              'Login Here',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColor.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
