import 'package:flutter/material.dart';
import '../vocabulary_storage.dart';
import '../models/vocabulary.dart';
import '../sample_words.dart'; // file chứa sampleWords

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirmed == true) {
      await onConfirm();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Thực hiện thành công")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙️ Cài đặt")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Xoá toàn bộ từ vựng"),
            onTap: () => _confirmAction(
              context,
              title: "Xoá tất cả?",
              message: "Bạn có chắc chắn muốn xoá toàn bộ từ vựng đã lưu?",
              onConfirm: () async => await VocabularyStorage.saveVocabulary([]),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text("Tải lại bộ từ mẫu"),
            onTap: () => _confirmAction(
              context,
              title: "Tải lại bộ từ mẫu?",
              message:
                  "Hành động này sẽ thay thế danh sách hiện tại bằng 20 từ mẫu.",
              onConfirm: () async =>
                  await VocabularyStorage.saveVocabulary(sampleWords),
            ),
          ),
        ],
      ),
    );
  }
}
