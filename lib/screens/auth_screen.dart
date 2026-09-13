import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/vault_provider.dart';
import '../providers/auth_settings_provider.dart';
import 'setup_screen.dart';
import '../widgets/gradient_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  String _pin = '';
  bool _isAuthenticating = false;
  bool _usePinFallback = false;
  bool _pinError = false;

  Future<void> _authWithBiometrics(AuthSettingsState settings) async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    
    HapticFeedback.lightImpact();

    final localAuth = ref.read(localAuthProvider);
    try {
      final bool canAuth = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
      if (!canAuth) {
        if (mounted) _goToDashboard();
        return;
      }

      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock your vault',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate && mounted) {
        _goToDashboard();
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onPinKey(String key, AuthSettingsState settings) {
    HapticFeedback.lightImpact();
    setState(() {
      _pinError = false;
      if (key == '<') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (key == 'C') {
        _pin = '';
      } else {
        if (_pin.length < 8) _pin += key;
      }
    });
  }

  void _verifyPin(AuthSettingsState settings) {
    if (_pin == settings.pin) {
      _goToDashboard();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _pinError = true;
        _pin = '';
      });
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final authSettingsState = ref.watch(authSettingsProvider);

    return authSettingsState.when(
      data: (settings) {
        if (settings.preference == null) return const SetupScreen();

        if (settings.preference == 'pin' || _usePinFallback) {
          return _buildPinUI(settings, _usePinFallback);
        } else {
          return _buildBiometricUI(settings);
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildBiometricUI(AuthSettingsState settings) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _authWithBiometrics(settings),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                ),
                child: const Icon(Icons.fingerprint, size: 50, color: Colors.white),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut)
              .boxShadow(begin: BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.2), blurRadius: 10), end: BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.6), blurRadius: 40), duration: 1000.ms),
            ),
            const SizedBox(height: 48),
            const Text('Tap to Unlock', style: TextStyle(fontSize: 20, color: Colors.white70)),
            if (settings.pin != null) ...[
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _usePinFallback = true);
                },
                child: const Text('Switch to PIN', style: TextStyle(color: Color(0xFF00F0FF))),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPinUI(AuthSettingsState settings, bool isFallback) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: Color(0xFF00F0FF))
                    .animate(target: _pinError ? 1 : 0)
                    .shakeX(duration: 400.ms),
                  const SizedBox(height: 16),
                  Text('Enter Vault PIN', style: TextStyle(fontSize: 20, color: _pinError ? Colors.redAccent : Colors.white70)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      8,
                      (index) {
                        if (index >= _pin.length && index >= 4) return const SizedBox.shrink();
                        bool isActive = index < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.1),
                            boxShadow: isActive ? [
                              BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.5), blurRadius: 8)
                            ] : [],
                          ),
                        ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 150.ms);
                      }
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int j = 1; j <= 3; j++)
                              _buildPinButton('${i * 3 + j}', settings),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPinButton('C', settings, icon: Icons.clear),
                          _buildPinButton('0', settings),
                          _buildPinButton('<', settings, icon: Icons.backspace_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  GradientButton(
                    width: double.infinity,
                    onPressed: _pin.isEmpty ? null : () => _verifyPin(settings),
                    child: const Text('Unlock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  if (isFallback) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _usePinFallback = false);
                      },
                      child: const Text('Use Biometrics', style: TextStyle(color: Color(0xFF8A2BE2))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(String value, AuthSettingsState settings, {IconData? icon}) {
    return InkWell(
      onTap: () => _onPinKey(value, settings),
      customBorder: const CircleBorder(),
      splashColor: const Color(0xFF00F0FF).withOpacity(0.3),
      highlightColor: const Color(0xFF8A2BE2).withOpacity(0.2),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: icon != null
            ? Icon(icon, size: 28, color: Colors.white70)
            : Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white)),
      ),
    );
  }
}
