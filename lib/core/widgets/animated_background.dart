import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Latar animasi mirip AnimatedBackgroundView di MPorT Android:
/// gradient gelap + bintang + garis jaringan cyan.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;
  final _rng = math.Random(2026);

  @override
  void initState() {
    super.initState();
    _stars = List.generate(48, (_) {
      return _Star(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: 0.6 + _rng.nextDouble() * 1.8,
        vx: (_rng.nextDouble() - 0.5) * 0.00025,
        vy: (_rng.nextDouble() - 0.5) * 0.00025,
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    for (final s in _stars) {
      s.x += s.vx;
      s.y += s.vy;
      if (s.x < 0 || s.x > 1) s.vx = -s.vx;
      if (s.y < 0 || s.y > 1) s.vy = -s.vy;
      s.x = s.x.clamp(0.0, 1.0);
      s.y = s.y.clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(_stars, _ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Star {
  double x, y, r, vx, vy;
  _Star({
    required this.x,
    required this.y,
    required this.r,
    required this.vx,
    required this.vy,
  });
}

class _BgPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _BgPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bgTop, AppColors.bgMiddle, AppColors.bgBottom],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // soft cyan/purple glow blobs
    final glow1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cyan.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.15),
        radius: size.width * 0.55,
      ));
    canvas.drawRect(rect, glow1);

    final glow2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.purple.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.7),
        radius: size.width * 0.5,
      ));
    canvas.drawRect(rect, glow2);

    // network edges
    final edgePaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < stars.length; i++) {
      for (var j = i + 1; j < stars.length; j++) {
        final a = stars[i];
        final b = stars[j];
        final dx = (a.x - b.x) * size.width;
        final dy = (a.y - b.y) * size.height;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < 90) {
          final alpha = (1 - d / 90) * 0.18;
          edgePaint.color = AppColors.cyan.withValues(alpha: alpha);
          canvas.drawLine(
            Offset(a.x * size.width, a.y * size.height),
            Offset(b.x * size.width, b.y * size.height),
            edgePaint,
          );
        }
      }
    }

    // stars
    final starPaint = Paint()..color = AppColors.cyan.withValues(alpha: 0.7);
    for (final s in stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter oldDelegate) => true;
}
