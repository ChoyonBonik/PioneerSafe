import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import '../models/vault_item.dart';
import '../repositories/secure_storage_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );
});

final secureStorageRepositoryProvider = Provider<SecureStorageRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageRepository(storage);
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

class VaultNotifier extends AsyncNotifier<List<VaultItem>> {
  @override
  Future<List<VaultItem>> build() async {
    final repo = ref.watch(secureStorageRepositoryProvider);
    return repo.loadItems();
  }

  Future<void> addItem(VaultItem item) async {
    final repo = ref.read(secureStorageRepositoryProvider);
    final currentState = state;
    if (currentState is AsyncData) {
      final updatedList = List<VaultItem>.from(currentState.value!)..add(item);
      state = AsyncValue.data(updatedList);
      await repo.saveItems(updatedList);
    }
  }

  Future<void> deleteItem(String id) async {
    final repo = ref.read(secureStorageRepositoryProvider);
    final currentState = state;
    if (currentState is AsyncData) {
      final items = currentState.value!;
      final index = items.indexWhere((element) => element.id == id);
      if (index != -1) {
        final item = items[index];
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        final updatedList = List<VaultItem>.from(items)..removeAt(index);
        state = AsyncValue.data(updatedList);
        await repo.saveItems(updatedList);
      }
    }
  }
}

final vaultProvider = AsyncNotifierProvider<VaultNotifier, List<VaultItem>>(() {
  return VaultNotifier();
});
