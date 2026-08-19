import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/guest/guest_screen.dart';
import '../../features/user/dashboard/user_shell.dart';
import '../../features/user/dashboard/user_home_screen.dart';
import '../../features/user/packages/packages_screen.dart';
import '../../features/user/invoices/invoices_screen.dart';
import '../../features/user/tickets/tickets_screen.dart';
import '../../features/user/profile/profile_screen.dart';
import '../../features/tech/home/tech_shell.dart';
import '../../features/tech/home/tech_home_screen.dart';
import '../../features/tech/jobs/tech_jobs_screen.dart';
import '../../features/tech/materials/tech_materials_screen.dart';
import '../../features/tech/map/tech_map_screen.dart';
import '../../features/admin/home/admin_shell.dart';
import '../../features/admin/home/admin_home_screen.dart';
import '../../features/admin/customers/admin_customers_screen.dart';
import '../../features/admin/invoices/admin_invoices_screen.dart';
import '../../features/admin/users/admin_users_screen.dart';

class AppRouter {
  static GoRouter create(AuthService auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final loading = auth.isLoading;
        final loggedIn = auth.isLoggedIn;
        final onboarded = auth.onboarded;

        if (loading) return loc == '/splash' ? null : '/splash';
        if (loc == '/splash') {
          if (!onboarded) return '/onboarding';
          if (!loggedIn) return '/login';
          return _homeForRole(auth.role);
        }
        if (!onboarded && loc != '/onboarding') return '/onboarding';
        if (loc == '/onboarding' && onboarded) {
          return loggedIn ? _homeForRole(auth.role) : '/login';
        }

        final public = {'/login', '/register', '/guest', '/onboarding'};
        if (!loggedIn && !public.contains(loc)) return '/login';
        if (loggedIn && (loc == '/login' || loc == '/register')) {
          return _homeForRole(auth.role);
        }

        // Role guards
        if (loggedIn) {
          if (loc.startsWith('/admin') && auth.role != 'admin') {
            return _homeForRole(auth.role);
          }
          if (loc.startsWith('/tech') &&
              auth.role != 'technician' &&
              auth.role != 'admin') {
            return _homeForRole(auth.role);
          }
          if (loc.startsWith('/app') &&
              auth.role != 'user' &&
              auth.role != 'admin') {
            // admin boleh masuk portal user jika perlu; technician tidak
            if (auth.role == 'technician') return _homeForRole(auth.role);
          }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/guest', builder: (_, __) => const GuestScreen()),

        // ── User (pelanggan) ──
        ShellRoute(
          builder: (context, state, child) => UserShell(child: child),
          routes: [
            GoRoute(path: '/app', builder: (_, __) => const UserHomeScreen()),
            GoRoute(path: '/app/packages', builder: (_, __) => const PackagesScreen()),
            GoRoute(path: '/app/invoices', builder: (_, __) => const InvoicesScreen()),
            GoRoute(path: '/app/tickets', builder: (_, __) => const TicketsScreen()),
            GoRoute(path: '/app/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),

        // ── Technician ──
        ShellRoute(
          builder: (context, state, child) => TechShell(child: child),
          routes: [
            GoRoute(path: '/tech', builder: (_, __) => const TechHomeScreen()),
            GoRoute(path: '/tech/jobs', builder: (_, __) => const TechJobsScreen()),
            GoRoute(path: '/tech/materials', builder: (_, __) => const TechMaterialsScreen()),
            GoRoute(path: '/tech/map', builder: (_, __) => const TechMapScreen()),
          ],
        ),

        // ── Admin ──
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
            GoRoute(path: '/admin/customers', builder: (_, __) => const AdminCustomersScreen()),
            GoRoute(path: '/admin/invoices', builder: (_, __) => const AdminInvoicesScreen()),
            GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
          ],
        ),
      ],
    );
  }

  static String _homeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'technician':
        return '/tech';
      default:
        return '/app';
    }
  }
}

/// Helper agar mudah dipakai di widget
extension AuthRoleX on BuildContext {
  AuthService get auth => read<AuthService>();
}
