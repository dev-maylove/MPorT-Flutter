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
