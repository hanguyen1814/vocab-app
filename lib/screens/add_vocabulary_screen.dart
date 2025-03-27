import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';

class AddVocabularyScreen extends StatefulWidget {
  const AddVocabularyScreen({super.key});

  @override
  State<AddVocabularyScreen> createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  Future<List<Vocabulary>> _getCurrentWords() async {
    return await VocabularyStorage.loadVocabulary();
  }

  Future<void> _saveSingleWord() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    final example = _exampleController.text.trim();

    if (word.isEmpty || meaning.isEmpty || example.isEmpty) return;

    final current = await _getCurrentWords();
    final exists =
        current.any((vocab) => vocab.word.toLowerCase() == word.toLowerCase());

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Từ "$word" đã tồn tại.')),
      );
      return;
    }

    current.add(Vocabulary(word: word, meaning: meaning, example: example));
    await VocabularyStorage.saveVocabulary(current);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm từ mới')),
    );

    _wordController.clear();
    _meaningController.clear();
    _exampleController.clear();
  }

  Future<void> _saveBatchWords() async {
    final input = _batchController.text.trim();
    if (input.isEmpty) return;

    final lines = input.split('\n');
    final newWords = <Vocabulary>[];
    final current = await _getCurrentWords();
    final existingWords = current.map((v) => v.word.toLowerCase()).toSet();

    for (var line in lines) {
      final parts = line.split('|');
      if (parts.length != 3) continue;

      final word = parts[0].trim();
      final meaning = parts[1].trim();
      final example = parts[2].trim();

      if (word.isNotEmpty && meaning.isNotEmpty && example.isNotEmpty) {
        if (!existingWords.contains(word.toLowerCase())) {
          newWords
              .add(Vocabulary(word: word, meaning: meaning, example: example));
          existingWords.add(word.toLowerCase());
        }
      }
    }

    if (newWords.isNotEmpty) {
      current.addAll(newWords);
      await VocabularyStorage.saveVocabulary(current);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Đã thêm ${newWords.length} từ mới (đã bỏ qua từ trùng)')),
      );

      _batchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có từ hợp lệ để thêm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm từ vựng')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('➕ Nhập từng từ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(labelText: 'Từ')),
              TextField(
                  controller: _meaningController,
                  decoration: const InputDecoration(labelText: 'Nghĩa')),
              TextField(
                  controller: _exampleController,
                  decoration: const InputDecoration(labelText: 'Ví dụ')),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _saveSingleWord,
                icon: const Icon(Icons.add),
                label: const Text('Thêm từ này'),
              ),
              const Divider(height: 32),
              const Text('📥 Nhập hàng loạt (từ | nghĩa | ví dụ mỗi dòng)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _batchController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'apple | quả táo | I eat an apple every morning.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _saveBatchWords,
                icon: const Icon(Icons.save_alt),
                label: const Text('Lưu danh sách'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
