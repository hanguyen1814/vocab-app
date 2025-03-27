import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';
import 'dart:math';
import 'dart:async';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  List<Vocabulary> allWords = [];
  List<Vocabulary> selectedWords = [];
  List<_GameCard> cards = [];
  List<int> revealedIndexes = [];
  List<int> matchedIndexes = [];
  bool isBusy = false;

  int difficultyPairs = 4;
  int incorrectAttempts = 0;
  int secondsElapsed = 0;
  Timer? timer;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    _loadAllWords();
  }

  Future<void> _loadAllWords() async {
    allWords = await VocabularyStorage.loadVocabulary();
    setState(() {});
  }

  void _startGame() {
    if (allWords.length < difficultyPairs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đủ từ để bắt đầu trò chơi.')),
      );
      return;
    }

    final random = Random();
    allWords.shuffle();
    selectedWords = allWords.take(difficultyPairs).toList();

    final tempCards = <_GameCard>[];
    for (var vocab in selectedWords) {
      tempCards.add(_GameCard(text: vocab.word, id: vocab.word));
      tempCards.add(_GameCard(text: vocab.meaning, id: vocab.word));
    }
    tempCards.shuffle();

    setState(() {
      cards = tempCards;
      revealedIndexes = [];
      matchedIndexes = [];
      incorrectAttempts = 0;
      secondsElapsed = 0;
      gameStarted = true;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void _onCardTap(int index) async {
    if (isBusy ||
        revealedIndexes.contains(index) ||
        matchedIndexes.contains(index)) return;

    setState(() {
      revealedIndexes.add(index);
    });

    if (revealedIndexes.length == 2) {
      final first = cards[revealedIndexes[0]];
      final second = cards[revealedIndexes[1]];

      if (first.id == second.id) {
        matchedIndexes.addAll(revealedIndexes);
        revealedIndexes.clear();

        if (matchedIndexes.length == cards.length) {
          timer?.cancel();
          await Future.delayed(const Duration(milliseconds: 500));
          _showWinDialog();
        }
      } else {
        isBusy = true;
        incorrectAttempts++;
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          revealedIndexes.clear();
        });
        isBusy = false;
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🎉 Hoàn thành!",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "⏱ Thời gian: ${secondsElapsed}s\n❌ Số lần sai: $incorrectAttempts"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text("🔄 Chơi lại"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("✖ Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("🎮 Ghép từ với nghĩa"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!gameStarted) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    const Text("🎯 Độ khó:",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: difficultyPairs,
                      items: const [
                        DropdownMenuItem(value: 4, child: Text("Dễ")),
                        DropdownMenuItem(value: 6, child: Text("Trung bình")),
                        DropdownMenuItem(value: 8, child: Text("Khó")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            difficultyPairs = value;
                          });
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _startGame,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Bắt đầu"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    )
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("⏱ ${secondsElapsed}s",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text("❌ $incorrectAttempts",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade300,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Chơi lại"),
                    )
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, index) {
                    final isRevealed = revealedIndexes.contains(index) ||
                        matchedIndexes.contains(index);
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isRevealed
                              ? Colors.lightBlue.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isRevealed)
                              BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 6,
                                  offset: const Offset(2, 2))
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          isRevealed ? cards[index].text : '❓',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _GameCard {
  final String text;
  final String id;

  _GameCard({required this.text, required this.id});
}
