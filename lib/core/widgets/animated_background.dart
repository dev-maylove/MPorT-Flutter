import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium dark mesh background: deep gradient, drifting orbs,
/// twinkling particles, and soft network lines.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  late final List<_Orb> _orbs;
  final _rng = math.Random(2026);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(56, (_) {
      final depth = 0.35 + _rng.nextDouble() * 0.65;
      return _Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: 0.4 + _rng.nextDouble() * 1.6 * depth,
        vx: (_rng.nextDouble() - 0.5) * 0.00018 * depth,
        vy: (_rng.nextDouble() - 0.5) * 0.00018 * depth,
        phase: _rng.nextDouble() * math.pi * 2,
        depth: depth,
      );
    });
    _orbs = [
      _Orb(
        nx: 0.18,
        ny: 0.12,
        radiusFactor: 0.55,
        color: AppColors.cyan,
        baseAlpha: 0.11,
        driftX: 0.03,
        driftY: 0.02,
        speed: 0.35,
        phase: 0.2,
      ),
      _Orb(
        nx: 0.82,
        ny: 0.28,
        radiusFactor: 0.48,
        color: AppColors.blue,
        baseAlpha: 0.09,
        driftX: -0.025,
        driftY: 0.03,
        speed: 0.28,
        phase: 1.4,
      ),
      _Orb(
        nx: 0.55,
        ny: 0.78,
        radiusFactor: 0.6,
        color: AppColors.purple,
        baseAlpha: 0.1,
        driftX: 0.02,
        driftY: -0.025,
        speed: 0.32,
        phase: 2.6,
      ),
      _Orb(
        nx: 0.12,
        ny: 0.65,
        radiusFactor: 0.35,
        color: const Color(0xFF00B8D4),
        baseAlpha: 0.06,
        driftX: 0.04,
        driftY: -0.015,
        speed: 0.4,
        phase: 3.8,
      ),
    ];
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _ctrl.addListener(_tick);
  }

  void _tick() {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0 || p.x > 1) p.vx = -p.vx;
      if (p.y < 0 || p.y > 1) p.vy = -p.vy;
      p.x = p.x.clamp(0.0, 1.0);
      p.y = p.y.clamp(0.0, 1.0);
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
        painter: _PremiumBgPainter(_particles, _orbs, _ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  double x, y, r, vx, vy, phase, depth;
  _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.vx,
    required this.vy,
    required this.phase,
    required this.depth,
  });
}

class _Orb {
  final double nx, ny, radiusFactor, baseAlpha, driftX, driftY, speed, phase;
  final Color color;
  const _Orb({
    required this.nx,
    required this.ny,
    required this.radiusFactor,
    required this.color,
    required this.baseAlpha,
    required this.driftX,
    required this.driftY,
    required this.speed,
    required this.phase,
  });
}

class _PremiumBgPainter extends CustomPainter {
  final List<_Particle> particles;
  final List<_Orb> orbs;
  final double t;

  _PremiumBgPainter(this.particles, this.orbs, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Deep multi-stop vertical gradient
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF05070E),
          Color(0xFF070B16),
          Color(0xFF04060C),
          Color(0xFF02040A),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Subtle aurora band
    final auroraY = size.height * (0.22 + 0.04 * math.sin(t * math.pi * 2));
    final aurora = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          AppColors.cyan.withValues(alpha: 0.04),
          AppColors.blue.withValues(alpha: 0.05),
          AppColors.purple.withValues(alpha: 0.035),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, auroraY - 40, size.width, 80));
    canvas.drawRect(Rect.fromLTWH(0, auroraY - 40, size.width, 80), aurora);

    // Drifting soft orbs
    final angle = t * math.pi * 2;
    for (final orb in orbs) {
      final ox = (orb.nx + orb.driftX * math.sin(angle * orb.speed + orb.phase)) *
          size.width;
      final oy = (orb.ny + orb.driftY * math.cos(angle * orb.speed + orb.phase)) *
          size.height;
      final radius = size.shortestSide * orb.radiusFactor;
      final pulse = 0.85 + 0.15 * math.sin(angle * orb.speed * 1.3 + orb.phase);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withValues(alpha: orb.baseAlpha * pulse),
            orb.color.withValues(alpha: orb.baseAlpha * 0.35 * pulse),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(ox, oy), radius: radius));
      canvas.drawCircle(Offset(ox, oy), radius, paint);
    }

    // Network edges between nearby particles
    final edgePaint = Paint()
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < particles.length; i++) {
      for (var j = i + 1; j < particles.length; j++) {
        final a = particles[i];
        final b = particles[j];
        final dx = (a.x - b.x) * size.width;
        final dy = (a.y - b.y) * size.height;
        final d = math.sqrt(dx * dx + dy * dy);
        final maxD = 100.0 * ((a.depth + b.depth) / 2);
        if (d < maxD) {
          final alpha = (1 - d / maxD) * 0.16 * ((a.depth + b.depth) / 2);
          edgePaint.color = AppColors.cyan.withValues(alpha: alpha);
          canvas.drawLine(
            Offset(a.x * size.width, a.y * size.height),
            Offset(b.x * size.width, b.y * size.height),
            edgePaint,
          );
        }
      }
    }

    // Twinkling particles
    for (final p in particles) {
      final twinkle =
          0.45 + 0.55 * (0.5 + 0.5 * math.sin(angle * 2.2 + p.phase));
      final alpha = (0.35 + 0.55 * p.depth) * twinkle;
      final center = Offset(p.x * size.width, p.y * size.height);

      // Soft glow halo
      final halo = Paint()
        ..color = AppColors.cyan.withValues(alpha: alpha * 0.22);
      canvas.drawCircle(center, p.r * 2.8, halo);

      final core = Paint()
        ..color = Color.lerp(
          AppColors.cyan,
          Colors.white,
          0.35 * p.depth,
        )!
            .withValues(alpha: alpha);
      canvas.drawCircle(center, p.r, core);
    }

    // Vignette for depth
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.05,
        colors: [
          Colors.transparent,
          const Color(0xFF000000).withValues(alpha: 0.45),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    // Top subtle film grain line (light scan)
    final scanY = size.height * ((t * 1.2) % 1.0);
    final scan = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, scanY - 1),
        Offset(0, scanY + 1),
        [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.015),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, scanY - 1, size.width, 2), scan);
  }

  @override
  bool shouldRepaint(covariant _PremiumBgPainter oldDelegate) => true;
}
