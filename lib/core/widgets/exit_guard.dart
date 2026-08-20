import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Double-back to exit + optional "first go to home tab" behaviour.
///
/// Wrap shell scaffolds so system back:
/// 1. Returns to [homePath] if not already there
/// 2. On home, requires a second press within 2s to leave the app
class ExitGuard extends StatefulWidget {
  final Widget child;
  final String homePath;
  final bool isOnHome;
  final VoidCallback? onGoHome;

  const ExitGuard({
    super.key,
    required this.child,
    required this.homePath,
    required this.isOnHome,
    this.onGoHome,
  });

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  DateTime? _lastBack;

  Future<void> _handleBack() async {
    if (!widget.isOnHome) {
      widget.onGoHome?.call();
      return;
    }

    final now = DateTime.now();
    if (_lastBack == null ||
        now.difference(_lastBack!) > const Duration(seconds: 2)) {
      _lastBack = now;
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tekan sekali lagi untuk keluar'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );
      return;
    }

    // Second press within window → exit
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: widget.child,
    );
  }
}
