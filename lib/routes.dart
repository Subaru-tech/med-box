import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_notice_screen.dart';
import 'screens/notice_history_screen.dart';
import 'screens/device_management_screen.dart';
import 'screens/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.createNotice:
        return MaterialPageRoute(builder: (_) => const CreateNoticeScreen());
      case AppRoutes.noticeHistory:
        return MaterialPageRoute(builder: (_) => const NoticeHistoryScreen());
      case AppRoutes.deviceManagement:
        return MaterialPageRoute(builder: (_) => const DeviceManagementScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
