import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String content;
  final List<String> options;
  final int correctAnswer; // Giữ nguyên kiểu int cho correctAnswer
  final String? explanation;
  final String? subject; // Trường mới, giữ nguyên
  final String? difficulty; // Trường mới, giữ nguyên
  final DateTime createdAt;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.subject,
    this.difficulty,
    required this.createdAt,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String createdAtString =
        data['createdAt'] as String? ?? DateTime.now().toIso8601String();

    return Question(
      id: doc.id,
      content: data['content'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] as int? ?? 0,
      explanation: data['explanation'] as String?,
      subject: data['subject'] as String?,
      difficulty: data['difficulty'] as String?,
      // Chuyển đổi String thành DateTime
      createdAt: DateTime.parse(createdAtString),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'subject': subject,
      'difficulty': difficulty,
      // Chuyển đổi DateTime thành String (ISO 8601)
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
