import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/vocabulary.dart';

class VocabularyStorage {
  static const _key = 'vocabularyList';

  static Future<List<Vocabulary>> loadVocabulary() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Vocabulary.fromJson(json)).toList();
  }

  static Future<void> saveVocabulary(List<Vocabulary> vocabList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = vocabList.map((vocab) => vocab.toJson()).toList();
    prefs.setString(_key, json.encode(jsonList));
  }

  static Future<void> addVocabulary(Vocabulary vocab) async {
    final current = await loadVocabulary();
    current.add(vocab);
    await saveVocabulary(current);
  }
}
