import 'dart:convert';
import 'package:uuid/uuid.dart';

class VaultItem {
  final String id;
  final String title;
  final String category;
  final String content;
  final String? imagePath;

  VaultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.imagePath,
  });

  factory VaultItem.create({
    required String title,
    required String category,
    required String content,
    String? imagePath,
  }) {
    return VaultItem(
      id: const Uuid().v4(),
      title: title,
      category: category,
      content: content,
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'imagePath': imagePath,
    };
  }

  factory VaultItem.fromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      content: map['content'],
      imagePath: map['imagePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VaultItem.fromJson(String source) => VaultItem.fromMap(json.decode(source));
}
