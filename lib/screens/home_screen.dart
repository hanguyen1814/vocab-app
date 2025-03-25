import 'package:flutter/material.dart';
import '../widgets/home_tile.dart';
import 'flashcard_screen.dart';
import 'add_vocabulary_screen.dart';
import 'vocabulary_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              const Text("Hello, Linh 👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Bạn đã học được 120 từ",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                        );
                      },
                    ),
                    const HomeTile(
                        icon: Icons.refresh,
                        label: "Ôn tập",
                        color: Colors.orange),
                    const HomeTile(
                        icon: Icons.videogame_asset,
                        label: "Trò chơi",
                        color: Colors.green),
                    const HomeTile(
                        icon: Icons.settings,
                        label: "Cài đặt",
                        color: Colors.grey),
                    HomeTile(
                      icon: Icons.add,
                      label: "Thêm từ",
                      color: Colors.purple,
                      onTap: () {
                        // print("Đã nhấn Thêm từ");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddVocabularyScreen()),
                        );
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
                        );
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
