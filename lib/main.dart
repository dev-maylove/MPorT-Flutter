import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/animated_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF06080F),
    ),
  );
  runApp(const MportApp());
}

class MportApp extends StatefulWidget {
  const MportApp({super.key});

  @override
  State<MportApp> createState() => _MportAppState();
}

class _MportAppState extends State<MportApp> {
  late final AuthService _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    // Create router once — recreating on every notifyListeners() resets navigation.
    _router = AppRouter.create(_auth);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'MPorT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const AnimatedBackground(),
              child ?? const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}
