import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/exit_guard.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _home = '/admin';

  int _index(String loc) {
    if (loc.startsWith('/admin/customers')) return 1;
    if (loc.startsWith('/admin/invoices')) return 2;
    if (loc.startsWith('/admin/users')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _index(loc);
    return ExitGuard(
      homePath: _home,
      isOnHome: idx == 0,
      onGoHome: () => context.go(_home),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          selectedIndex: idx,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/admin');
              case 1:
                context.go('/admin/customers');
              case 2:
                context.go('/admin/invoices');
              case 3:
                context.go('/admin/users');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Ops',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Pelanggan',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Invoice',
            ),
            NavigationDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              selectedIcon: Icon(Icons.manage_accounts_rounded),
              label: 'Users',
            ),
          ],
        ),
      ),
    );
  }
}
