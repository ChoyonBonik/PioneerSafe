import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // 2.5 second delay
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    // Check auth preference
    final settings = ref.read(authSettingsProvider).value;
    if (settings == null || settings.preference == null) {
      Navigator.pushReplacementNamed(context, '/setup');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00F0FF), Color(0xFF8A2BE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.lock_outline,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SECURE VAULT',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
          ],
        ).animate()
         .fadeIn(duration: 1500.ms, curve: Curves.easeOut)
         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 1500.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}
