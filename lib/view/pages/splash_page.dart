import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/view/pages/dashboard_page.dart';
import 'package:kavana_app/view/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/splash';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  late AnimationController _taglineController;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  late AnimationController _orbController;
  late Animation<double> _orbFadeAnimation;
  late Animation<Offset> _orbSlideAnimation;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _orbFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _orbController,
      curve: Curves.easeIn,
    ));
    _orbSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(
      parent: _orbController,
      curve: Curves.easeOut,
    ));

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_logoController);

    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _taglineFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    ));
    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    ));

    _orbController.forward();
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _logoController.forward();
    });
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _taglineController.forward();
    });

    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    final user = await Session.getUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } else {
      Navigator.pushReplacementNamed(context, DashboardPage.routeName);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  Widget _buildOrb(Color color, double size, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: FadeTransition(
        opacity: _orbFadeAnimation,
        child: SlideTransition(
          position: _orbSlideAnimation,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surface,
      body: Stack(
        children: [
          _buildOrb(
            AppColor.surfaceLightYellow,
            200,
            const Alignment(-1.5, 0.6),
          ),
          _buildOrb(
            AppColor.surfaceLightBlue.withOpacity(0.9),
            250,
            const Alignment(1.5, -0.8),
          ),
          _buildOrb(
            AppColor.primary.withOpacity(0.6),
            150,
            const Alignment(1.2, 0.6),
          ),
          _buildOrb(
            AppColor.secondary.withOpacity(0.8),
            180,
            const Alignment(0, -1.2),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Image.asset(
                      'assets/images/logo-kavana.png',
                      width: 350,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _taglineFadeAnimation,
                  child: SlideTransition(
                    position: _taglineSlideAnimation,
                    child: const Text(
                      "“Your Daily Poem of Self.”",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColor.textTitle,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

