import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';

/// Premium dark mesh background — 777 particles @ ~30 fps.
/// Edges use a spatial grid so cost stays ~O(n), not O(n²).
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with WidgetsBindingObserver {
  /// Dense starfield
  static const int particleCount = 777;
  static const int _frameUs = 1000000 ~/ 48; // ~48 fps target

  late final List<_Particle> _particles;
  late final List<_Orb> _orbs;
  final _rng = math.Random(2026);

  Ticker? _ticker;
  int _lastUs = 0;
  double _t = 0;
  bool _visible = true;

  final _bgPaint = Paint();
  final _orbPaint = Paint();
  final _edgePaint = Paint()
    ..strokeWidth = 0.7
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final _haloPaint = Paint();
  final _corePaint = Paint();
  final _vignettePaint = Paint();
  final _auroraPaint = Paint();
  final _cityStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter;
  final _cityWindow = Paint()..style = PaintingStyle.fill;

  /// Deterministic skyline blueprint (normalized width fractions + height factors).
  late final List<_Building> _skyline;

  Size? _shaderSize;

  // Spatial grid scratch (rebuilt each paint, lists reused)
  final List<List<int>> _grid = [];
  int _gridCols = 0;
  int _gridRows = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _particles = List.generate(particleCount, (i) {
      final depth = 0.25 + _rng.nextDouble() * 0.75;
      // Mostly tiny dots; few larger “anchor” stars
      final isAnchor = i % 17 == 0;
      return _Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        r: isAnchor
            ? 0.9 + _rng.nextDouble() * 1.4 * depth
            : 0.25 + _rng.nextDouble() * 0.85 * depth,
        vx: (_rng.nextDouble() - 0.5) * 0.00135 * depth,
        vy: (_rng.nextDouble() - 0.5) * 0.00135 * depth,
        phase: _rng.nextDouble() * math.pi * 2,
        depth: depth,
        // Only ~1/4 of particles join the network mesh
        link: isAnchor || _rng.nextDouble() < 0.22,
      );
    });

    _orbs = const [
      _Orb(0.18, 0.14, 0.5, AppColors.cyan, 0.1, 0.028, 0.018, 0.32, 0.2),
      _Orb(0.8, 0.3, 0.42, AppColors.blue, 0.08, -0.022, 0.025, 0.26, 1.4),
      _Orb(0.52, 0.78, 0.52, AppColors.purple, 0.09, 0.018, -0.022, 0.3, 2.6),
    ];

    // Wireframe city skyline (fixed layout, scales with screen width)
    final skyRng = math.Random(77);
    final buildings = <_Building>[];
    var x = 0.0;
    while (x < 1.02) {
      final bw = 0.035 + skyRng.nextDouble() * 0.055;
      final bh = 0.12 + skyRng.nextDouble() * 0.28;
      final floors = 4 + skyRng.nextInt(10);
      final cols = 2 + skyRng.nextInt(3);
      final hasAntenna = skyRng.nextDouble() < 0.28;
      final hasSpire = skyRng.nextDouble() < 0.18;
      buildings.add(_Building(
        x: x,
        w: bw,
        h: bh,
        floors: floors,
        cols: cols,
        antenna: hasAntenna,
        spire: hasSpire,
        seed: skyRng.nextInt(1 << 20),
      ));
      x += bw + 0.006 + skyRng.nextDouble() * 0.012;
    }
    // Landmark tower near center-right
    buildings.add(const _Building(
      x: 0.62,
      w: 0.07,
      h: 0.42,
      floors: 16,
      cols: 3,
      antenna: true,
      spire: true,
      seed: 2026,
    ));
    _skyline = buildings;

    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_visible) return;
    final us = elapsed.inMicroseconds;
    if (us - _lastUs < _frameUs) return;
    _lastUs = us;

    // Faster phase so stars / aurora / city windows feel more alive
    _t = (us / 5.5e6) % 1.0;

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.x <= 0) {
        p.x = 0;
        p.vx = p.vx.abs();
      } else if (p.x >= 1) {
        p.x = 1;
        p.vx = -p.vx.abs();
      }
      if (p.y <= 0) {
        p.y = 0;
        p.vy = p.vy.abs();
      } else if (p.y >= 1) {
        p.y = 1;
        p.vy = -p.vy.abs();
      }
    }

    setState(() {});
  }

  void _ensureShaders(Size size) {
    if (_shaderSize == size) return;
    _shaderSize = size;
    final rect = Offset.zero & size;
    // Semi-transparent dark wash so login content stays readable
    // and stars / city remain vivid.
    _bgPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF05070E).withValues(alpha: 0.55),
        const Color(0xFF070B16).withValues(alpha: 0.50),
        const Color(0xFF04060C).withValues(alpha: 0.48),
        const Color(0xFF02040A).withValues(alpha: 0.52),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(rect);
    _vignettePaint.shader = const RadialGradient(
      center: Alignment.center,
      radius: 1.05,
      colors: [Colors.transparent, Color(0x44000000)],
      stops: [0.60, 1.0],
    ).createShader(rect);
  }

  void _buildGrid(Size size, double cellPx) {
    final cols = math.max(1, (size.width / cellPx).ceil());
    final rows = math.max(1, (size.height / cellPx).ceil());
    final cells = cols * rows;
    if (_gridCols != cols || _gridRows != rows || _grid.length != cells) {
      _gridCols = cols;
      _gridRows = rows;
      _grid
        ..clear()
        ..addAll(List.generate(cells, (_) => <int>[]));
    } else {
      for (final cell in _grid) {
        cell.clear();
      }
    }

    final n = _particles.length;
    for (var i = 0; i < n; i++) {
      final p = _particles[i];
      if (!p.link) continue;
      final cx = (p.x * (cols - 1)).round().clamp(0, cols - 1);
      final cy = (p.y * (rows - 1)).round().clamp(0, rows - 1);
      _grid[cy * cols + cx].add(i);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (_visible) {
      _ticker?.start();
    } else {
      _ticker?.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BgPainter(
          particles: _particles,
          orbs: _orbs,
          skyline: _skyline,
          t: _t,
          ensureShaders: _ensureShaders,
          buildGrid: _buildGrid,
          grid: _grid,
          gridCols: () => _gridCols,
          gridRows: () => _gridRows,
          bgPaint: _bgPaint,
          orbPaint: _orbPaint,
          edgePaint: _edgePaint,
          haloPaint: _haloPaint,
          corePaint: _corePaint,
          vignettePaint: _vignettePaint,
          auroraPaint: _auroraPaint,
          cityStroke: _cityStroke,
          cityWindow: _cityWindow,
        ),
        size: Size.infinite,
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

class _Particle {
  double x, y, r, vx, vy, phase, depth;
  bool link;
  _Particle({
    required this.x,
    required this.y,
    required this.r,
    required this.vx,
    required this.vy,
    required this.phase,
    required this.depth,
    required this.link,
  });
}

class _Orb {
  final double nx, ny, radiusFactor, baseAlpha, driftX, driftY, speed, phase;
  final Color color;
  const _Orb(
    this.nx,
    this.ny,
    this.radiusFactor,
    this.color,
    this.baseAlpha,
    this.driftX,
    this.driftY,
    this.speed,
    this.phase,
  );
}

class _Building {
  final double x, w, h;
  final int floors, cols, seed;
  final bool antenna, spire;
  const _Building({
    required this.x,
    required this.w,
    required this.h,
    required this.floors,
    required this.cols,
    required this.antenna,
    required this.spire,
    required this.seed,
  });
}

class _BgPainter extends CustomPainter {
  final List<_Particle> particles;
  final List<_Orb> orbs;
  final List<_Building> skyline;
  final double t;
  final void Function(Size) ensureShaders;
  final void Function(Size, double) buildGrid;
  final List<List<int>> grid;
  final int Function() gridCols;
  final int Function() gridRows;
  final Paint bgPaint;
  final Paint orbPaint;
  final Paint edgePaint;
  final Paint haloPaint;
  final Paint corePaint;
  final Paint vignettePaint;
  final Paint auroraPaint;
  final Paint cityStroke;
  final Paint cityWindow;

  static const double _cellPx = 72;
  static const double _maxD = 72;
  static const double _maxD2 = _maxD * _maxD;
  static const int _maxEdges = 220;

  _BgPainter({
    required this.particles,
    required this.orbs,
    required this.skyline,
    required this.t,
    required this.ensureShaders,
    required this.buildGrid,
    required this.grid,
    required this.gridCols,
    required this.gridRows,
    required this.bgPaint,
    required this.orbPaint,
    required this.edgePaint,
    required this.haloPaint,
    required this.corePaint,
    required this.vignettePaint,
    required this.auroraPaint,
    required this.cityStroke,
    required this.cityWindow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    ensureShaders(size);
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    final short = size.shortestSide;

    canvas.drawRect(rect, bgPaint);

    final angle = t * math.pi * 2;

    // Aurora
    final auroraY = h * (0.22 + 0.035 * math.sin(angle));
    final auroraRect = Rect.fromLTWH(0, auroraY - 36, w, 72);
    auroraPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        AppColors.cyan.withValues(alpha: 0.06),
        AppColors.blue.withValues(alpha: 0.07),
        AppColors.purple.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(auroraRect);
    canvas.drawRect(auroraRect, auroraPaint);

    // Orbs
    for (final orb in orbs) {
      final ox =
          (orb.nx + orb.driftX * math.sin(angle * orb.speed + orb.phase)) * w;
      final oy =
          (orb.ny + orb.driftY * math.cos(angle * orb.speed + orb.phase)) * h;
      final radius = short * orb.radiusFactor;
      final pulse =
          0.88 + 0.12 * math.sin(angle * orb.speed * 1.2 + orb.phase);
      orbPaint.shader = RadialGradient(
        colors: [
          orb.color.withValues(alpha: orb.baseAlpha * pulse),
          orb.color.withValues(alpha: orb.baseAlpha * 0.3 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(ox, oy), radius: radius));
      canvas.drawCircle(Offset(ox, oy), radius, orbPaint);
    }

    // Wireframe city skyline (line art)
    _drawCity(canvas, size, angle);

    // Spatial-grid edges (only link particles, capped)
    buildGrid(size, _cellPx);
    final cols = gridCols();
    final rows = gridRows();
    var edges = 0;
    if (cols > 0 && rows > 0) {
      for (var cy = 0; cy < rows && edges < _maxEdges; cy++) {
        for (var cx = 0; cx < cols && edges < _maxEdges; cx++) {
          final cell = grid[cy * cols + cx];
          if (cell.isEmpty) continue;
          // Same cell pairs
          for (var a = 0; a < cell.length && edges < _maxEdges; a++) {
            final ia = cell[a];
            final pa = particles[ia];
            final ax = pa.x * w;
            final ay = pa.y * h;
            for (var b = a + 1; b < cell.length && edges < _maxEdges; b++) {
              edges += _tryEdge(canvas, ax, ay, pa, particles[cell[b]], w, h);
            }
            // Neighbor cells (right, down, diag) to avoid double-count
            for (final o in const [
              [1, 0],
              [0, 1],
              [1, 1],
              [1, -1],
            ]) {
              final nx = cx + o[0];
              final ny = cy + o[1];
              if (nx < 0 || ny < 0 || nx >= cols || ny >= rows) continue;
              final other = grid[ny * cols + nx];
              for (final ib in other) {
                if (edges >= _maxEdges) break;
                edges += _tryEdge(canvas, ax, ay, pa, particles[ib], w, h);
              }
            }
          }
        }
      }
    }

    // Particles — brighter cores + stronger halo
    for (final p in particles) {
      final twinkle =
          0.65 + 0.35 * (0.5 + 0.5 * math.sin(angle * 2.8 + p.phase));
      final alpha = (0.48 + 0.52 * p.depth) * twinkle;
      final c = Offset(p.x * w, p.y * h);

      if (p.r > 0.75 || p.link) {
        haloPaint.color = AppColors.cyan.withValues(alpha: alpha * 0.28);
        canvas.drawCircle(c, p.r * 2.6, haloPaint);
      }

      corePaint.color = AppColors.cyan.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(c, p.r * 1.15, corePaint);
    }

    canvas.drawRect(rect, vignettePaint);
  }

  int _tryEdge(
    Canvas canvas,
    double ax,
    double ay,
    _Particle a,
    _Particle b,
    double w,
    double h,
  ) {
    final bx = b.x * w;
    final by = b.y * h;
    final dx = ax - bx;
    final dy = ay - by;
    final d2 = dx * dx + dy * dy;
    if (d2 >= _maxD2 || d2 < 1) return 0;
    final d = math.sqrt(d2);
    edgePaint.color = AppColors.cyan.withValues(
      alpha: (1 - d / _maxD) * 0.20 * ((a.depth + b.depth) * 0.5),
    );
    canvas.drawLine(Offset(ax, ay), Offset(bx, by), edgePaint);
    return 1;
  }

  void _drawCity(Canvas canvas, Size size, double angle) {
    final w = size.width;
    final h = size.height;
    final ground = h * 0.92;
    final maxBuildingH = h * 0.38;

    // Skyline palette: hijau glow terang
    const skyBase = Color(0xFF00E676); // green base
    const skyBright = Color(0xFF69FFB0); // green highlight glow
    const skyGlow = Color(0xFF00FF9C); // neon glow

    // Horizon base line
    cityStroke
      ..strokeWidth = 1.25
      ..color = skyGlow.withValues(alpha: 0.65);
    canvas.drawLine(Offset(0, ground), Offset(w, ground), cityStroke);

    // Soft ground fill strip
    cityWindow.color = const Color(0x4000E676);
    canvas.drawRect(
      Rect.fromLTRB(0, ground, w, h),
      cityWindow,
    );

    for (final b in skyline) {
      final left = b.x * w;
      final bw = b.w * w;
      final bh = b.h * maxBuildingH * (0.85 + 0.15 * ((b.seed % 10) / 10));
      final top = ground - bh;
      final right = left + bw;
      if (right < -4 || left > w + 4) continue;

      // Building outline
      cityStroke
        ..strokeWidth = 1.35
        ..color = skyBase.withValues(alpha: 0.70);
      final outline = Path()
        ..moveTo(left, ground)
        ..lineTo(left, top)
        ..lineTo(right, top)
        ..lineTo(right, ground);
      canvas.drawPath(outline, cityStroke);

      // Roof line accent
      cityStroke
        ..strokeWidth = 1.7
        ..color = skyBright.withValues(alpha: 0.85);
      canvas.drawLine(Offset(left, top), Offset(right, top), cityStroke);

      // Spire / peak
      if (b.spire) {
        final mid = (left + right) / 2;
        final peak = top - bh * 0.12;
        cityStroke
          ..strokeWidth = 1.25
          ..color = skyGlow.withValues(alpha: 0.90);
        canvas.drawLine(Offset(left + bw * 0.2, top), Offset(mid, peak), cityStroke);
        canvas.drawLine(Offset(right - bw * 0.2, top), Offset(mid, peak), cityStroke);
      }

      // Floor lines (horizontal)
      cityStroke
        ..strokeWidth = 0.8
        ..color = skyBase.withValues(alpha: 0.42);
      final floorH = bh / (b.floors + 1);
      for (var f = 1; f <= b.floors; f++) {
        final fy = top + floorH * f;
        canvas.drawLine(Offset(left + 1, fy), Offset(right - 1, fy), cityStroke);
      }

      // Column lines (vertical)
      cityStroke
        ..strokeWidth = 0.75
        ..color = skyBase.withValues(alpha: 0.38);
      final colW = bw / (b.cols + 1);
      for (var c = 1; c <= b.cols; c++) {
        final cx = left + colW * c;
        canvas.drawLine(Offset(cx, top + 1), Offset(cx, ground - 1), cityStroke);
      }

      // Window dots — bright green glow + twinkle
      final padX = bw * 0.14;
      final padY = bh * 0.08;
      final cellW = (bw - padX * 2) / b.cols;
      final cellH = (bh - padY * 2) / b.floors;
      for (var row = 0; row < b.floors; row++) {
        for (var col = 0; col < b.cols; col++) {
          // Deterministic “lit” windows
          final lit = ((b.seed + row * 17 + col * 31) % 7) > 2;
          if (!lit) continue;
          final tw =
              0.80 + 0.20 * math.sin(angle * 2.0 + (b.seed + row + col) * 0.37);
          final wx = left + padX + cellW * (col + 0.5);
          final wy = top + padY + cellH * (row + 0.5);
          final rw = cellW * 0.34;
          final rh = cellH * 0.34;
          cityWindow.color = skyBright.withValues(alpha: 0.45 * tw);
          canvas.drawRect(
            Rect.fromCenter(center: Offset(wx, wy), width: rw, height: rh),
            cityWindow,
          );
        }
      }
    }

    // Perspective street lines (vanishing toward lower center)
    final vanish = Offset(w * 0.5, ground + h * 0.02);
    cityStroke
      ..strokeWidth = 0.95
      ..color = skyGlow.withValues(alpha: 0.35);
    for (final fx in [0.15, 0.3, 0.45, 0.55, 0.7, 0.85]) {
      canvas.drawLine(Offset(w * fx, ground), vanish, cityStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
