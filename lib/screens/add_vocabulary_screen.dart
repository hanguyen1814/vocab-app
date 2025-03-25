import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';

class AddVocabularyScreen extends StatefulWidget {
  const AddVocabularyScreen({super.key});

  @override
  State<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();

  Future<void> _saveVocabulary() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    final example = _exampleController.text.trim();

    if (word.isEmpty || meaning.isEmpty || example.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final vocab = Vocabulary(word: word, meaning: meaning, example: example);
    await VocabularyStorage.addVocabulary(vocab);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu từ vựng!')),
    );

    Navigator.pop(context); // quay lại màn hình trước
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm từ mới')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(labelText: 'Từ mới'),
            ),
            TextField(
              controller: _meaningController,
              decoration: const InputDecoration(labelText: 'Nghĩa'),
            ),
            TextField(
              controller: _exampleController,
              decoration: const InputDecoration(labelText: 'Ví dụ'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveVocabulary,
              child: const Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
