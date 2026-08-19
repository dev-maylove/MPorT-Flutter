import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  final _pages = const [
    _PageData(
      icon: Icons.speed_rounded,
      title: 'Internet stabil',
      body: 'Cek paket, status layanan, dan tagihan dalam satu aplikasi.',
    ),
    _PageData(
      icon: Icons.receipt_long_rounded,
      title: 'Tagihan transparan',
      body: 'Lihat invoice, jatuh tempo, dan konfirmasi pembayaran dengan mudah.',
    ),
    _PageData(
      icon: Icons.support_agent_rounded,
      title: 'Dukungan cepat',
      body: 'Buat ticket dan hubungi CS / teknisi kapan saja.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Lewati', style: TextStyle(color: AppColors.muted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 88, color: AppColors.cyan),
                        const SizedBox(height: 28),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppColors.cyan : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_index < _pages.length - 1) {
                    _page.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
                child: Text(_index < _pages.length - 1 ? 'Lanjut' : 'Mulai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await context.read<AuthService>().setOnboarded();
    if (mounted) context.go('/login');
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String body;
  const _PageData({required this.icon, required this.title, required this.body});
}
