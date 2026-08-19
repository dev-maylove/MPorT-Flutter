import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class TechShell extends StatelessWidget {
  final Widget child;
  const TechShell({super.key, required this.child});

  int _index(String loc) {
    if (loc.startsWith('/tech/jobs')) return 1;
    if (loc.startsWith('/tech/materials')) return 2;
    if (loc.startsWith('/tech/map')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _index(loc);
    return Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.92),
            selectedIndex: idx,
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/tech');
                case 1:
                  context.go('/tech/jobs');
                case 2:
                  context.go('/tech/materials');
                case 3:
                  context.go('/tech/map');
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work_rounded), label: 'Jobs'),
              NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'Material'),
              NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Map'),
            ],
          ),
    );
  }
}
