import 'package:flutter/material.dart';
import '../widgets/home_tile.dart';
import 'flashcard_screen.dart';
import 'add_vocabulary_screen.dart';
import 'vocabulary_list_screen.dart';
import 'review_screen.dart';
import 'matching_game_screen.dart';
import 'settings_screen.dart';
import '../models/vocabulary.dart';
import '../vocabulary_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalWords = 0;
  int learnedWords = 0;

  @override
  void initState() {
    super.initState();
    _loadWordStats();
  }

  Future<void> _loadWordStats() async {
    final list = await VocabularyStorage.loadVocabulary();
    setState(() {
      totalWords = list.length;
      learnedWords = list.where((v) => v.isLearned).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hi 👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("📚 Đã học: $learnedWords / $totalWords từ",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    HomeTile(
                      icon: Icons.menu_book,
                      label: "Học từ vựng",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FlashcardScreen()),
                        ).then((_) => _loadWordStats());
                      },
                    ),
                    HomeTile(
                      icon: Icons.refresh,
                      label: "Ôn tập",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReviewScreen()),
                        );
                      },
                    ),
                    HomeTile(
                      icon: Icons.videogame_asset,
                      label: "Trò chơi",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MatchingGameScreen()),
                        );
                      },
                    ),
                    HomeTile(
                      icon: Icons.settings,
                      label: "Cài đặt",
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ).then((_) => _loadWordStats());
                      },
                    ),
                    HomeTile(
                      icon: Icons.add,
                      label: "Thêm từ",
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddVocabularyScreen()),
                        ).then((_) => _loadWordStats());
                      },
                    ),
                    HomeTile(
                      icon: Icons.list,
                      label: "Danh sách từ",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VocabularyListScreen()),
                        ).then((_) => _loadWordStats());
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
