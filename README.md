# MPorT Flutter — MandalaNet Portal

Role-based ISP portal for **MPorT Laravel v2.0.1**.

## Android build matrix (Flutter 3.47 verified)

| Component | Version |
|-----------|---------|
| Gradle | **9.3.1** |
| AGP | **9.1.0** |
| Kotlin (KGP) | **2.4.0** |
| Java | **17** |

## API URL

Default: `http://192.168.1.102:8000`

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.102:8000
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.102:8000
```

## Setup

```bash
flutter pub get
flutter run
```

## GitHub Actions

- **CI** — analyze + test on push/PR
- **Build APK** — manual / tag `v*`
- **Release** — APK + AAB + GitHub Release on tag

```bash
git tag v2.0.2
git push origin v2.0.2
```

---

## Changelog

### 2026-08-20 — Login screen UX

- Hapus subtitle *“Portal pelanggan & teknisi MandalaNet”*.
- Judul diganti **MPorT** (tanpa kata “Masuk”).
- Hapus opsi **Lanjut sebagai tamu**.
- Tambah **Lupa password?** (dialog + `POST /api/auth/forgot-password`).
- Login menerima **email / nomor HP / ID** (field `login` + `email` ke API).

### 2026-08-20 — Wireframe city skyline

- Procedural **line-art city** at the bottom of the animated background.
- Building outlines, floor/column grids, spires, antennas, sparse glowing windows.
- Horizon base line + perspective street lines; window brightness twinkles lightly with time.
- Deterministic layout (seeded) so the skyline stays stable across frames.

### 2026-08-20 — Particle field & performance

- **Background particles raised to 777** (`AnimatedBackground.particleCount`).
- Spatial **grid** for network edges (≈O(n), not O(n²)); only ~¼ of particles participate in mesh; **max 220 edges**/frame.
- Halo drawn only for larger / link particles to cut overdraw.
- Animation capped at **~30 fps** via throttled `Ticker`.
- **Pause** animation when app is not resumed (`WidgetsBindingObserver`).
- Reused `Paint` objects; gradient/vignette shaders cached per size.
- `RepaintBoundary` + `isComplex` / `willChange` on the background layer.

### 2026-08-20 — Premium background

- Multi-stop dark gradient, drifting cyan/blue/purple orbs, aurora band, twinkle, vignette.

### 2026-08-20 — System back / exit behaviour

- Added `ExitGuard`: on shell tabs, first back returns to **home tab**; on home (or login), **double-back within 2s** exits with snackbar *“Tekan sekali lagi untuk keluar”*.
- Applied to User / Tech / Admin shells and Login screen.
- Routes opened with `push` (Register, Guest) still pop normally.

### 2026-08-20 — Bugfixes (stability)

- **GoRouter** created once in `initState` (was recreated on every `AuthService.notifyListeners()`, resetting navigation).
- `DropdownButtonFormField`: `initialValue` → **`value`** (compile/runtime API fix) in admin users, tickets, tech materials.
- Safe **int parsing** for material IDs (JSON `num`/`String` no longer crashes).
- Dispose **TextEditingController**s after dialogs/bottom sheets; dispose **MapController** on tech map.
- Widget test: mock `SharedPreferences` + binding so tests do not hang.
- Normalized `if (!mounted) return;` early-exits across feature screens.

---

## Architecture notes

| Area | Path |
|------|------|
| Auth / session | `lib/core/auth/auth_service.dart` |
| HTTP client | `lib/core/api/` |
| Router + role guards | `lib/core/router/app_router.dart` |
| Animated background | `lib/core/widgets/animated_background.dart` |
| Double-back exit | `lib/core/widgets/exit_guard.dart` |
| Role shells | `lib/features/{user,tech,admin}/**/` |
