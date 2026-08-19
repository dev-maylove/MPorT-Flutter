import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass.dart';

/// Alias ke [GlassCard] — backward compatible.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}

/// Metric chip — sekarang memakai [GlassStat] style.
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassStat(
        label: label,
        value: value,
        color: color,
      ),
    );
  }
}
