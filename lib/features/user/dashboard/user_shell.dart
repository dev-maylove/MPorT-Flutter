import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/exit_guard.dart';

class UserShell extends StatelessWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  static const _home = '/app';

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
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.wifi_outlined),
              selectedIcon: Icon(Icons.wifi_rounded),
              label: 'Paket',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Tagihan',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent_rounded),
              label: 'Ticket',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
