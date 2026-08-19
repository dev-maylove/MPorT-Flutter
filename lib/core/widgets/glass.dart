import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Glassmorphism UI Kit — MPorT Flutter
//  Konsisten dengan AppColors + AnimatedBackground.
// ═══════════════════════════════════════════════════════════════════════════

/// Radius standar glass
class GlassRadius {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const full = 999.0;
}

/// Intensity preset untuk blur & opacity
enum GlassIntensity {
  /// Blur ringan, cocok list item / chip
  subtle,

  /// Default card
  regular,

  /// Dialog, sheet, panel penting
  strong,
}

extension on GlassIntensity {
  double get blur => switch (this) {
        GlassIntensity.subtle => 8,
        GlassIntensity.regular => 16,
        GlassIntensity.strong => 28,
      };

  double get fillOpacity => switch (this) {
        GlassIntensity.subtle => 0.28,
        GlassIntensity.regular => 0.42,
        GlassIntensity.strong => 0.55,
      };

  double get borderOpacity => switch (this) {
        GlassIntensity.subtle => 0.35,
        GlassIntensity.regular => 0.55,
        GlassIntensity.strong => 0.75,
      };
}

// ─────────────────────────────────────────────────────────────────────────
//  Core: GlassContainer
// ─────────────────────────────────────────────────────────────────────────

/// Container glassmorphism generik (blur + tint + border + optional glow).
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final GlassIntensity intensity;
  final Color? tint;
  final Color? borderColor;
  final double borderWidth;
  final bool enableGlow;
  final Color? glowColor;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = GlassRadius.md,
    this.intensity = GlassIntensity.regular,
    this.tint,
    this.borderColor,
    this.borderWidth = 1.0,
    this.enableGlow = false,
    this.glowColor,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final baseTint = tint ?? AppColors.card;
    final fill = baseTint.withValues(alpha: intensity.fillOpacity);
    final border = (borderColor ?? AppColors.borderCyan)
        .withValues(alpha: intensity.borderOpacity);
    final glow = glowColor ?? AppColors.cyan;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: gradient == null ? fill : null,
      gradient: gradient,
      border: Border.all(color: border, width: borderWidth),
      boxShadow: boxShadow ??
          (enableGlow
              ? [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]),
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: intensity.blur,
            sigmaY: intensity.blur,
          ),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            alignment: alignment,
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassCard — drop-in replacement AppCard / GlassCard lama
// ─────────────────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlassIntensity intensity;
  final double borderRadius;
  final bool enableGlow;
  final Color? tint;
  final Color? borderColor;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.intensity = GlassIntensity.regular,
    this.borderRadius = GlassRadius.md,
    this.enableGlow = false,
    this.tint,
    this.borderColor,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      intensity: intensity,
      tint: tint,
      borderColor: showBorder ? (borderColor ?? AppColors.borderCyan) : Colors.transparent,
      borderWidth: showBorder ? 1.0 : 0,
      enableGlow: enableGlow,
      width: double.infinity,
      child: child,
    );

    if (onTap == null && onLongPress == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.cyan.withValues(alpha: 0.12),
        highlightColor: AppColors.cyan.withValues(alpha: 0.06),
        child: card,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassPanel — section / group container (lebih besar, subtle)
// ─────────────────────────────────────────────────────────────────────────

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final String? title;
  final Widget? trailing;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.title,
    this.trailing,
    this.borderRadius = GlassRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      intensity: GlassIntensity.subtle,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassAppBar
// ─────────────────────────────────────────────────────────────────────────

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double height;
  final bool implyLeading;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.height = kToolbarHeight + 8,
    this.implyLeading = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.55),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderCyan.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight,
                child: NavigationToolbar(
                  leading: leading ??
                      (implyLeading && canPop
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.text,
                              onPressed: () => Navigator.maybePop(context),
                            )
                          : null),
                  middle: titleWidget ??
                      (title != null
                          ? Text(
                              title!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : null),
                  trailing: actions != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        )
                      : null,
                  centerMiddle: centerTitle,
                  middleSpacing: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassBottomBar — NavigationBar glass
// ─────────────────────────────────────────────────────────────────────────

class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassBottomItem> items;
  final Color? accent;

  const GlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.cyan;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: AppColors.borderCyan.withValues(alpha: 0.4),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final selected = i == currentIndex;
                  return Expanded(
                    child: _GlassNavItem(
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      label: item.label,
                      selected: selected,
                      accent: color,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(i);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const GlassBottomItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _GlassNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? (activeIcon ?? icon) : icon,
              size: 22,
              color: selected ? accent : AppColors.muted2,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : AppColors.muted2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassButton
// ─────────────────────────────────────────────────────────────────────────

enum GlassButtonVariant { filled, outlined, ghost, soft }

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonVariant variant;
  final Color? color;
  final bool expanded;
  final bool loading;
  final double height;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = GlassButtonVariant.filled,
    this.color,
    this.expanded = true,
    this.loading = false,
    this.height = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cyan;
    final enabled = onPressed != null && !loading;

    Widget content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: variant == GlassButtonVariant.filled
                  ? const Color(0xFF001014)
                  : c,
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18, color: _fg(c)),
          const SizedBox(width: 8),
        ],
        if (!loading)
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: _fg(c),
            ),
          ),
      ],
    );

    final child = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: content,
    );

    switch (variant) {
      case GlassButtonVariant.filled:
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: c,
            foregroundColor: const Color(0xFF001014),
            disabledBackgroundColor: c.withValues(alpha: 0.35),
            elevation: 0,
            shadowColor: c.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: child,
        );
      case GlassButtonVariant.outlined:
        return OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: c,
            side: BorderSide(color: c.withValues(alpha: enabled ? 0.9 : 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: child,
        );
      case GlassButtonVariant.ghost:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: c,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: child,
        );
      case GlassButtonVariant.soft:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: GlassContainer(
              height: height,
              borderRadius: borderRadius,
              intensity: GlassIntensity.subtle,
              tint: c,
              borderColor: c,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
    }
  }

  Color _fg(Color c) {
    if (variant == GlassButtonVariant.filled) {
      return const Color(0xFF001014);
    }
    return c;
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassIconButton
// ─────────────────────────────────────────────────────────────────────────

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;
  final bool enableGlow;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 42,
    this.tooltip,
    this.enableGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cyan;
    final btn = GlassContainer(
      width: size,
      height: size,
      borderRadius: size / 2.6,
      intensity: GlassIntensity.subtle,
      tint: AppColors.card,
      borderColor: c.withValues(alpha: 0.45),
      enableGlow: enableGlow,
      glowColor: c,
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.45, color: c),
    );

    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2.6),
        child: btn,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: tappable);
    }
    return tappable;
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassTextField
// ─────────────────────────────────────────────────────────────────────────

class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onFieldSubmitted: onSubmitted,
              maxLines: maxLines,
              enabled: enabled,
              validator: validator,
              style: const TextStyle(color: AppColors.text, fontSize: 15),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                hintText: hint,
                errorText: errorText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.65),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
                ),
                hintStyle: const TextStyle(color: AppColors.muted2),
                errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassChip / StatusBadge
// ─────────────────────────────────────────────────────────────────────────

class GlassChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onTap;

  const GlassChip({
    super.key,
    required this.label,
    this.color = AppColors.cyan,
    this.icon,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? color.withValues(alpha: 0.22)
        : color.withValues(alpha: 0.12);
    final border = color.withValues(alpha: filled ? 0.55 : 0.35);

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GlassRadius.full),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

/// Status badge siap pakai (paid, pending, open, closed, dll)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase().trim();
    final (label, color, icon) = _map(s);
    return GlassChip(label: label, color: color, icon: icon, filled: true);
  }

  (String, Color, IconData) _map(String s) {
    if (s.contains('paid') || s.contains('lunas') || s.contains('success') || s == 'active' || s == 'online') {
      return ('Lunas', AppColors.success, Icons.check_circle_rounded);
    }
    if (s.contains('pending') || s.contains('menunggu') || s.contains('unpaid') || s == 'open') {
      return (s.contains('open') ? 'Open' : 'Pending', AppColors.warning, Icons.schedule_rounded);
    }
    if (s.contains('overdue') || s.contains('late') || s.contains('failed') || s.contains('cancel') || s == 'offline' || s == 'closed') {
      return (s.contains('closed') ? 'Closed' : 'Overdue', AppColors.danger, Icons.error_rounded);
    }
    if (s.contains('progress') || s.contains('process')) {
      return ('Proses', AppColors.blue, Icons.sync_rounded);
    }
    return (status, AppColors.muted, Icons.info_outline_rounded);
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassStat — metric tile
// ─────────────────────────────────────────────────────────────────────────

class GlassStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;

  const GlassStat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.cyan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      intensity: GlassIntensity.subtle,
      borderColor: color.withValues(alpha: 0.35),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassListTile
// ─────────────────────────────────────────────────────────────────────────

class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? accent;

  const GlassListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: padding,
      intensity: GlassIntensity.subtle,
      borderRadius: GlassRadius.md,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: accent ?? AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onTap != null)
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted2, size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassDialog / GlassSheet helpers
// ─────────────────────────────────────────────────────────────────────────

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim, secondary) {
      return SafeArea(
        child: Center(
          child: builder(ctx),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secondary, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class GlassDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;

  const GlassDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.maxWidth = 340,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: maxWidth,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      borderRadius: GlassRadius.lg,
      intensity: GlassIntensity.strong,
      enableGlow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 14),
          ],
          content,
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actions!.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions![i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: builder(ctx),
      );
    },
  );
}

class GlassSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? heightFactor;

  const GlassSheet({
    super.key,
    required this.child,
    this.title,
    this.heightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * (heightFactor ?? 0.7);

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.borderCyan.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 14),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassShimmer — skeleton loading
// ─────────────────────────────────────────────────────────────────────────

class GlassShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GlassShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _ctrl.value, 0),
              end: Alignment(-1.0 + 2.0 * _ctrl.value + 0.6, 0),
              colors: [
                AppColors.card.withValues(alpha: 0.4),
                AppColors.cyan.withValues(alpha: 0.08),
                AppColors.card.withValues(alpha: 0.4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card placeholder
class GlassSkeletonCard extends StatelessWidget {
  final double height;

  const GlassSkeletonCard({super.key, this.height = 88});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      intensity: GlassIntensity.subtle,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: height - 32,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassShimmer(width: 120, height: 14),
            SizedBox(height: 12),
            GlassShimmer(height: 12),
            SizedBox(height: 8),
            GlassShimmer(width: 180, height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassEmpty / GlassError — empty & error state
// ─────────────────────────────────────────────────────────────────────────

class GlassEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GlassEmpty({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          intensity: GlassIntensity.subtle,
          enableGlow: true,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, size: 30, color: AppColors.cyan),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                GlassButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expanded: false,
                  variant: GlassButtonVariant.soft,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlassError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const GlassError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassEmpty(
      icon: Icons.cloud_off_rounded,
      title: 'Terjadi kesalahan',
      subtitle: message,
      actionLabel: onRetry != null ? 'Coba lagi' : null,
      onAction: onRetry,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassDivider
// ─────────────────────────────────────────────────────────────────────────

class GlassDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const GlassDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.borderCyan.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  GlassAvatar
// ─────────────────────────────────────────────────────────────────────────

class GlassAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double radius;
  final Color? color;

  const GlassAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.radius = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cyan;
    final initials = _initials(name);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withValues(alpha: 0.35),
            c.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.2),
            blurRadius: 12,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(imageUrl!, fit: BoxFit.cover)
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.w800,
                  color: c,
                ),
              ),
            ),
    );
  }

  String _initials(String? n) {
    if (n == null || n.trim().isEmpty) return '?';
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
