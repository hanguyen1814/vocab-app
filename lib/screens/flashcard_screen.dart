import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

enum FilterMode { all, learned, unlearned }

class _FlashcardScreenState extends State<FlashcardScreen> {
  FilterMode _filterMode = FilterMode.unlearned;

  List<Vocabulary> vocabularyList = [];
  int currentIndex = 0;
  bool showBack = false;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final list = await VocabularyStorage.loadVocabulary();
    setState(() {
      vocabularyList = list.where((vocab) {
        switch (_filterMode) {
          case FilterMode.learned:
            return vocab.isLearned;
          case FilterMode.unlearned:
            return !vocab.isLearned;
          case FilterMode.all:
          default:
            return true;
        }
      }).toList();
    });
  }

  void nextCard() {
    setState(() {
      showBack = false;
      if (vocabularyList.isNotEmpty) {
        currentIndex = (currentIndex + 1) % vocabularyList.length;
      }
    });
  }

  void flipCard() {
    setState(() {
      showBack = !showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (vocabularyList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcards")),
        body:
            const Center(child: Text("Chưa có từ vựng nào. Hãy thêm từ mới!")),
      );
    }

    final card = vocabularyList[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Flashcards")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: DropdownButton<FilterMode>(
                isExpanded: true,
                value: _filterMode,
                items: const [
                  DropdownMenuItem(
                    value: FilterMode.unlearned,
                    child: Text("📘 Chỉ từ chưa học"),
                  ),
                  DropdownMenuItem(
                    value: FilterMode.learned,
                    child: Text("✅ Chỉ từ đã học"),
                  ),
                  DropdownMenuItem(
                    value: FilterMode.all,
                    child: Text("📚 Tất cả từ"),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() {
                      _filterMode = mode;
                    });
                    _loadVocabulary(); // Tải lại theo chế độ mới
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: flipCard,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 300,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      showBack ? Colors.orange.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: showBack
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(card.meaning,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(card.example,
                                style: const TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic)),
                          ],
                        )
                      : Text(card.word,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: nextCard,
              child: const Text('Tiếp theo'),
            ),
          ],
        ),
      ),
    );
  }
}
