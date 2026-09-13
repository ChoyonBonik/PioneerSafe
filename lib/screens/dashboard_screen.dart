import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/vault_provider.dart';
import 'item_detail_screen.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'license':
        return Icons.badge_outlined;
      case 'key':
        return Icons.key_outlined;
      case 'password':
        return Icons.password_outlined;
      case 'note':
      default:
        return Icons.note_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(vaultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.white70),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.invalidate(vaultProvider);
              Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
            },
          ),
        ],
      ),
      body: vaultState.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ]
                    ),
                    child: const Icon(Icons.lock_outline, size: 80, color: Color(0xFF00F0FF)),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
                  const SizedBox(height: 32),
                  const Text(
                    'Your vault is completely empty',
                    style: TextStyle(fontSize: 18, color: Colors.white54, letterSpacing: 1.2),
                  ).animate().fadeIn(delay: 500.ms, duration: 1000.ms),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  onDismissed: (direction) {
                    HapticFeedback.heavyImpact();
                    ref.read(vaultProvider.notifier).deleteItem(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.title} deleted')),
                    );
                  },
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getIconForCategory(item.category), color: const Color(0xFF00F0FF)),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text(item.category, style: const TextStyle(color: Colors.white54)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
                .animate()
                .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic, delay: (index * 100).ms)
                .fadeIn(duration: 400.ms, delay: (index * 100).ms),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00F0FF), Color(0xFF8A2BE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/editor');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
