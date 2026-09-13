import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vault_provider.dart';

class AuthSettingsState {
  final String? preference;
  final String? pin;
  AuthSettingsState({this.preference, this.pin});
}

class AuthSettingsNotifier extends AsyncNotifier<AuthSettingsState> {
  @override
  Future<AuthSettingsState> build() async {
    final repo = ref.watch(secureStorageRepositoryProvider);
    final pref = await repo.getAuthPreference();
    final pin = await repo.getVaultPin();
    return AuthSettingsState(preference: pref, pin: pin);
  }

  Future<void> setPreference(String pref) async {
    final repo = ref.read(secureStorageRepositoryProvider);
    await repo.setAuthPreference(pref);
    state = AsyncData(AuthSettingsState(preference: pref, pin: state.value?.pin));
  }

  Future<void> setPin(String pin) async {
    final repo = ref.read(secureStorageRepositoryProvider);
    await repo.setVaultPin(pin);
    state = AsyncData(AuthSettingsState(preference: state.value?.preference, pin: pin));
  }
}

final authSettingsProvider = AsyncNotifierProvider<AuthSettingsNotifier, AuthSettingsState>(() {
  return AuthSettingsNotifier();
});
