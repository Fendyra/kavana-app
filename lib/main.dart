import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavana_app/common/app_color.dart';
import 'package:kavana_app/core/session.dart';
import 'package:kavana_app/data/models/solution_model.dart';
import 'package:kavana_app/view/pages/account_page.dart';
import 'package:kavana_app/view/pages/agenda/add_agenda_page.dart';
import 'package:kavana_app/view/pages/agenda/all_agenda_page.dart';
import 'package:kavana_app/view/pages/agenda/detail_agenda_page.dart';
import 'package:kavana_app/view/pages/chat_ai_page.dart';
import 'package:kavana_app/view/pages/dashboard_page.dart';
import 'package:kavana_app/view/pages/finance/add_savings_page.dart';
import 'package:kavana_app/view/pages/finance/currency_converter_page.dart';
import 'package:kavana_app/view/pages/login_page.dart';
import 'package:kavana_app/view/pages/mood/choose_mood_page.dart';
import 'package:kavana_app/view/pages/register_page.dart';
import 'package:kavana_app/view/pages/solution/add_solution_page.dart';
import 'package:kavana_app/view/pages/solution/detail_solution_page.dart';
import 'package:kavana_app/view/pages/solution/update_solution_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeTimeZones();
  runApp(const MainApp());
}

Future<void> _initializeTimeZones() async {
  tz.initializeTimeZones();
  try {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (e) {
    print('Could not get local timezone: $e');
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: AppColor.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColor.primary,
          secondary: AppColor.secondary,
          surface: AppColor.surface,
          surfaceContainer: AppColor.surfaceContainer,
          error: AppColor.error,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        shadowColor: AppColor.primary.withOpacity(0.3),
      ),
      home: FutureBuilder(
        future: Session.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) return const LoginPage();
          return const DashboardPage();
        },
      ),
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        DashboardPage.routeName: (context) => const DashboardPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        AccountPage.routeName: (context) => const AccountPage(),
        ChooseMoodPage.routeName: (context) => const ChooseMoodPage(),
        AllAgendaPage.routeName: (context) => const AllAgendaPage(),
        AddAgendaPage.routeName: (context) => const AddAgendaPage(),
        DetailAgendaPage.routeName: (context) {
          int agendaId = ModalRoute.of(context)!.settings.arguments as int;
          return DetailAgendaPage(agendaId: agendaId);
        },
        AddSolutionPage.routeName: (context) => const AddSolutionPage(),
        UpdateSolutionPage.routeName: (context) {
          SolutionModel solution =
              ModalRoute.of(context)!.settings.arguments as SolutionModel;
          return UpdateSolutionPage(solution: solution);
        },
        DetailSolutionPage.routeName: (context) {
          int solutionId = ModalRoute.of(context)!.settings.arguments as int;
          return DetailSolutionPage(solutionId: solutionId);
        },
        ChatAIPage.routeName: (context) => const ChatAIPage(),
        AddSavingsPage.routeName: (context) => const AddSavingsPage(),
        CurrencyConverterPage.routeName: (context) {
          ModalRoute.of(context)!.settings.arguments as double;
          return const CurrencyConverterPage();
        },
      },
    );
  }
}
