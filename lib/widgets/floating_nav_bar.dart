import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/alert_provider.dart';
import '../providers/shell_nav_provider.dart';
import 'glass_container.dart';

class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavDestination(this.icon, this.activeIcon, this.label);
}

const _destinations = [
  _NavDestination(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavDestination(
      Icons.medication_outlined, Icons.medication_rounded, 'Medicines'),
  _NavDestination(
      Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 'Messages'),
  _NavDestination(Icons.event_outlined, Icons.event_rounded, 'Appointments'),
  _NavDestination(Icons.notifications_none_rounded, Icons.notifications_rounded,
      'Alerts'),
];

/// ElderLink's signature bottom navigation — a floating glass capsule with
/// a gradient pill that slides beneath the active tab.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ShellNavProvider>().index;
    final hasActiveAlerts =
        context.watch<AlertProvider>().activeAlerts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        blur: 20,
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: 60,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                    -1 + (2 * selected) / (_destinations.length - 1), 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / _destinations.length,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(_destinations.length, (i) {
                  final dest = _destinations[i];
                  final isSelected = i == selected;
                  final color =
                      isSelected ? Colors.white : AppColors.textHint;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () =>
                          context.read<ShellNavProvider>().setIndex(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? dest.activeIcon : dest.icon,
                                color: color,
                                size: 21,
                              ),
                              if (i == 4 && hasActiveAlerts)
                                Positioned(
                                  right: -4,
                                  top: -2,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.background,
                                          width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dest.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
