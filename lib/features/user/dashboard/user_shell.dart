import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class UserShell extends StatelessWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  int _index(String loc) {
    if (loc.startsWith('/app/packages')) return 1;
    if (loc.startsWith('/app/invoices')) return 2;
    if (loc.startsWith('/app/tickets')) return 3;
    if (loc.startsWith('/app/profile')) return 4;
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
                  context.go('/app');
                case 1:
                  context.go('/app/packages');
                case 2:
                  context.go('/app/invoices');
                case 3:
                  context.go('/app/tickets');
                case 4:
                  context.go('/app/profile');
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
              NavigationDestination(icon: Icon(Icons.wifi_outlined), selectedIcon: Icon(Icons.wifi_rounded), label: 'Paket'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Tagihan'),
              NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent_rounded), label: 'Ticket'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
            ],
          ),
    );
  }
}
