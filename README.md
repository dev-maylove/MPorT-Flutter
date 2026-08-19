# MPorT Flutter — MandalaNet Portal

Role-based ISP portal for **MPorT Laravel v2.0.1**.

**Version:** 2.0.3 — includes Glassmorphism UI Kit.

## What's new in 2.0.3

- Full **Glassmorphism UI Kit** (`lib/core/widgets/glass.dart`)
  - `GlassContainer`, `GlassCard`, `GlassPanel`
  - `GlassAppBar`, `GlassBottomBar`
  - `GlassButton`, `GlassIconButton`, `GlassTextField`
  - `GlassStat`, `GlassChip`, `StatusBadge`, `GlassListTile`, `GlassAvatar`
  - `GlassDialog` / `showGlassDialog`, `GlassSheet` / `showGlassSheet`
  - `GlassShimmer`, `GlassSkeletonCard`, `GlassEmpty`, `GlassError`
- `AppCard` & `StatChip` now delegate to the glass kit (backward compatible)
- Examples: `lib/core/widgets/glass_examples.dart`

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

## Roles & routes

| Role | Home | Screens |
|------|------|---------|
| **User** | `/app` | Packages, Invoices, Tickets, Profile |
| **Technician** | `/tech` | Jobs, Materials, Map |
| **Admin** | `/admin` | Customers, Invoices, Users |

## Glassmorphism quick start

```dart
import 'package:mport/core/widgets/glass.dart';

GlassCard(
  enableGlow: true,
  onTap: () {},
  child: Text('Hello'),
)

StatusBadge(status: 'paid')

GlassButton(label: 'Bayar', onPressed: () {})
```

## GitHub Actions

- **CI** — analyze + test on push/PR
- **Build APK** — manual / tag `v*`
- **Release** — APK + AAB + GitHub Release on tag

```bash
git tag v2.0.3
git push origin v2.0.3
```
