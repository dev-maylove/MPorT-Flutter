import 'package:flutter/material.dart';

import 'animated_background.dart';

/// Scaffold gelap transparan + AnimatedBackground (semua halaman).
///
/// Untuk kartu glassmorphism, gunakan:
/// - `AppCard` dari `app_card.dart` (alias)
/// - `GlassCard` / komponen lain dari `glass.dart`
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AnimatedBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          extendBody: extendBody,
        ),
      ],
    );
  }
}
