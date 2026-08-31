import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';
import 'screens/dashboard_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/elder_device_screen.dart';
import 'screens/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.medications:
        return MaterialPageRoute(builder: (_) => const MedicationsScreen());
      case AppRoutes.messages:
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      case AppRoutes.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case AppRoutes.alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
      case AppRoutes.elderDevice:
        return MaterialPageRoute(builder: (_) => const ElderDeviceScreen());
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
