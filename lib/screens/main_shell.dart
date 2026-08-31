import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shell_nav_provider.dart';
import '../widgets/floating_nav_bar.dart';
import 'alerts_screen.dart';
import 'appointments_screen.dart';
import 'dashboard_screen.dart';
import 'medications_screen.dart';
import 'messages_screen.dart';

/// Hosts the five primary sections behind a persistent floating nav bar,
/// preserving each tab's state instead of pushing full-screen routes.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.watch<ShellNavProvider>().index;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DashboardScreen(),
          MedicationsScreen(),
          MessagesScreen(),
          AppointmentsScreen(),
          AlertsScreen(),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}
