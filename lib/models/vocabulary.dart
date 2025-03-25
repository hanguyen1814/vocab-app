class Vocabulary {
  final String word;
  final String meaning;
  final String example;
  bool isLearned; // ← thêm dòng này

  Vocabulary({
    required this.word,
    required this.meaning,
    required this.example,
    this.isLearned = false, // mặc định là chưa học
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'meaning': meaning,
        'example': example,
        'isLearned': isLearned,
      };

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      word: json['word'],
      meaning: json['meaning'],
      example: json['example'],
      isLearned: json['isLearned'] ?? false, // để tương thích với dữ liệu cũ
    );
  }
}
