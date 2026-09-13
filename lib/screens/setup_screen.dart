import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_settings_provider.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/gradient_button.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Vault')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFF00F0FF))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2000.ms),
            const SizedBox(height: 32),
            const Text(
              'Choose how you want to secure your vault:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GradientButton(
              width: double.infinity,
              onPressed: () async {
                HapticFeedback.lightImpact();
                await ref.read(authSettingsProvider.notifier).setPreference('biometric');
                if (context.mounted) Navigator.pushReplacementNamed(context, '/auth');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Use Biometrics', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.pin),
              label: const Text('Set a Custom PIN'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                side: const BorderSide(color: Color(0xFF00F0FF)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final pin = await showPinSetupDialog(context);
                if (pin != null) {
                  await ref.read(authSettingsProvider.notifier).setPin(pin);
                  await ref.read(authSettingsProvider.notifier).setPreference('pin');
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/auth');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
