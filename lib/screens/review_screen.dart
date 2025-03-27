import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';
import 'dart:math';

enum FilterMode { all, learned, unlearned }

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Vocabulary> allWords = [];
  late Vocabulary currentQuestion;
  List<String> options = [];

  String? selectedAnswer;
  bool isCorrect = false;

  int score = 0;
  int questionCount = 0;
  final int maxQuestions = 10;

  FilterMode _filterMode = FilterMode.unlearned;
  bool quizFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final words = await VocabularyStorage.loadVocabulary();
    final filtered = words.where((vocab) {
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

    filtered.shuffle();

    setState(() {
      score = 0;
      questionCount = 0;
      quizFinished = false;
      allWords = filtered.take(30).toList(); // tránh trùng lặp nếu nhiều từ
    });

    _generateQuestion();
  }

  void _generateQuestion() {
    if (questionCount >= maxQuestions || allWords.length < 4) {
      setState(() {
        quizFinished = true;
      });
      return;
    }

    final rand = Random();
    currentQuestion =
        allWords.removeAt(rand.nextInt(allWords.length)); // Avoid repetition

    final wrongOptions = allWords
        .map((v) => v.meaning)
        .toSet()
        .difference({currentQuestion.meaning}).toList()
      ..shuffle();

    options = [
      currentQuestion.meaning,
      ...wrongOptions.take(3),
    ]..shuffle();

    setState(() {
      selectedAnswer = null;
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == currentQuestion.meaning;
      if (isCorrect) score++;
      questionCount++;
    });
  }

  void _next() {
    setState(() {
      selectedAnswer = null;
    });
    _generateQuestion();
  }

  void _restart() {
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown filter
            DropdownButton<FilterMode>(
              value: _filterMode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: FilterMode.unlearned,
                    child: Text("📘 Chỉ từ chưa học")),
                DropdownMenuItem(
                    value: FilterMode.learned, child: Text("✅ Chỉ từ đã học")),
                DropdownMenuItem(
                    value: FilterMode.all, child: Text("📚 Tất cả")),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  setState(() {
                    _filterMode = mode;
                  });
                  _loadQuestions();
                }
              },
            ),
            const SizedBox(height: 16),

            if (quizFinished)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎉 Bạn đã hoàn thành!',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('Điểm số: $score / $maxQuestions',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _restart,
                        child: const Text('Làm lại'),
                      )
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                'Câu ${questionCount} / $maxQuestions',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                'Từ: ${currentQuestion.word}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...options.map((option) {
                final isSelected = selectedAnswer == option;
                final isCorrectAnswer = option == currentQuestion.meaning;

                Color? tileColor;
                if (selectedAnswer != null) {
                  if (isSelected) {
                    tileColor =
                        isCorrectAnswer ? Colors.green : Colors.red.shade300;
                  } else if (isCorrectAnswer) {
                    tileColor = Colors.green.shade100;
                  }
                }

                return GestureDetector(
                  onTap: selectedAnswer == null
                      ? () => _checkAnswer(option)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tileColor ?? Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                );
              }),
              const SizedBox(height: 24),
              if (selectedAnswer != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: const Text('Tiếp theo'),
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
