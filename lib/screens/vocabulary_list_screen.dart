import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  List<Vocabulary> vocabularyList = [];

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadVocabulary() async {
    final list = await VocabularyStorage.loadVocabulary();
    setState(() {
      vocabularyList = list;
    });
  }

  Future<void> _deleteVocabulary(int index) async {
    vocabularyList.removeAt(index);
    await VocabularyStorage.saveVocabulary(vocabularyList);
    setState(() {}); // cập nhật lại danh sách
  }

  void _editVocabulary(int index) {
    final vocab = vocabularyList[index];
    final wordController = TextEditingController(text: vocab.word);
    final meaningController = TextEditingController(text: vocab.meaning);
    final exampleController = TextEditingController(text: vocab.example);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chỉnh sửa từ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: "Từ")),
            TextField(
                controller: meaningController,
                decoration: const InputDecoration(labelText: "Nghĩa")),
            TextField(
                controller: exampleController,
                decoration: const InputDecoration(labelText: "Ví dụ")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () async {
              vocabularyList[index] = Vocabulary(
                word: wordController.text.trim(),
                meaning: meaningController.text.trim(),
                example: exampleController.text.trim(),
              );
              await VocabularyStorage.saveVocabulary(vocabularyList);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = vocabularyList.where((vocab) {
      return vocab.word.toLowerCase().contains(_searchKeyword) ||
          vocab.meaning.toLowerCase().contains(_searchKeyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách từ vựng")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm từ vựng...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Không tìm thấy kết quả"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final vocab = filteredList[index];
                      final realIndex = vocabularyList.indexOf(vocab);
                      return ListTile(
                        title: Text(vocab.word),
                        subtitle: Text(vocab.meaning),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                vocab.isLearned
                                    ? Icons.check_circle
                                    : Icons.hourglass_bottom,
                                color: vocab.isLearned
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                setState(() {
                                  vocab.isLearned = !vocab.isLearned;
                                });
                                await VocabularyStorage.saveVocabulary(
                                    vocabularyList);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editVocabulary(realIndex),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteVocabulary(realIndex),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
