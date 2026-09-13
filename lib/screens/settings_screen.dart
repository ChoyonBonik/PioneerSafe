import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_settings_provider.dart';
import '../widgets/pin_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSettings = ref.watch(authSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: authSettings.when(
        data: (settings) {
          final pref = settings.preference ?? 'biometric';
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Unlock Preference', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
              RadioListTile<String>(
                title: const Text('Biometrics'),
                subtitle: const Text('Use Fingerprint or Face ID'),
                value: 'biometric',
                groupValue: pref,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) {
                  if (val != null) ref.read(authSettingsProvider.notifier).setPreference(val);
                },
              ),
              RadioListTile<String>(
                title: const Text('Custom PIN'),
                subtitle: const Text('Use a numeric PIN to unlock'),
                value: 'pin',
                groupValue: pref,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) async {
                  if (val != null) {
                    if (settings.pin == null) {
                      final newPin = await showPinSetupDialog(context);
                      if (newPin != null) {
                        await ref.read(authSettingsProvider.notifier).setPin(newPin);
                        await ref.read(authSettingsProvider.notifier).setPreference('pin');
                      }
                    } else {
                      ref.read(authSettingsProvider.notifier).setPreference(val);
                    }
                  }
                },
              ),
              const Divider(height: 32),
              if (settings.pin != null)
                ListTile(
                  leading: Icon(Icons.password, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Change PIN'),
                  onTap: () async {
                    final newPin = await showPinSetupDialog(context);
                    if (newPin != null) {
                      await ref.read(authSettingsProvider.notifier).setPin(newPin);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PIN updated successfully')),
                        );
                      }
                    }
                  },
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
