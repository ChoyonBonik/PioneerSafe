import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vault_item.dart';
import '../providers/vault_provider.dart';
import '../widgets/glass_card.dart';

class ItemDetailScreen extends ConsumerWidget {
  final VaultItem item;

  const ItemDetailScreen({super.key, required this.item});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'license':
        return Icons.badge;
      case 'key':
        return Icons.key;
      case 'password':
        return Icons.password;
      case 'note':
      default:
        return Icons.note;
    }
  }

  void _deleteItem(BuildContext context, WidgetRef ref) {
    ref.read(vaultProvider.notifier).deleteItem(item.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteItem(context, ref),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForCategory(item.category), size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Text(
                  item.category,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Secure Content:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                item.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (item.imagePath != null) ...[
              const Text(
                'Attached Image:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
