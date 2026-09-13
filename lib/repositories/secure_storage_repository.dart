import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/vault_item.dart';

class SecureStorageRepository {
  final FlutterSecureStorage _storage;

  SecureStorageRepository(this._storage);

  static const _itemsKey = 'vault_items';

  Future<void> saveItems(List<VaultItem> items) async {
    final List<Map<String, dynamic>> mapList = items.map((item) => item.toMap()).toList();
    final String jsonString = json.encode(mapList);
    await _storage.write(key: _itemsKey, value: jsonString);
  }

  Future<List<VaultItem>> loadItems() async {
    final String? jsonString = await _storage.read(key: _itemsKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((map) => VaultItem.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static const _authPrefKey = 'auth_pref';
  static const _vaultPinKey = 'vault_pin';

  Future<String?> getAuthPreference() async => await _storage.read(key: _authPrefKey);
  Future<void> setAuthPreference(String pref) async => await _storage.write(key: _authPrefKey, value: pref);

  Future<String?> getVaultPin() async => await _storage.read(key: _vaultPinKey);
  Future<void> setVaultPin(String pin) async => await _storage.write(key: _vaultPinKey, value: pin);
}
