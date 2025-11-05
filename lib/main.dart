import 'package:flutter/material.dart';
import 'package:nexstep/pages/dashboard_page.dart';
import 'package:nexstep/pages/login_page.dart';
import 'package:nexstep/pages/main_navigation.dart';
import 'package:nexstep/pages/signup_page.dart';
import 'package:nexstep/pages/target_info_page.dart';
import 'package:nexstep/pages/training_plans_page.dart';
import 'package:nexstep/pages/welcome_page.dart';
import 'package:nexstep/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/main_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexStep',
      theme: MainTheme.darkTheme,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/target-info': (context) => const TargetInfoPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/training-plans': (context) => const TrainingPlansPage(),
        '/main-nav': (context) => const MainNavigation(),
      },
    );
  }
}

final supabase = Supabase.instance.client;
