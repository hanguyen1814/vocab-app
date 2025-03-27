import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_vocabulary_screen.dart';
import 'sample_words.dart';
import 'vocabulary_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final current = await VocabularyStorage.loadVocabulary();
  if (current.isEmpty) {
    await VocabularyStorage.saveVocabulary(sampleWords);
  }

  runApp(const VocaBoostApp());
}

class VocaBoostApp extends StatelessWidget {
  const VocaBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocaBoost',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(),
      routes: {
        '/add': (context) => const AddVocabularyScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
