import 'package:cloud_firestore/cloud_firestore.dart';

class Formula {
  final String id;
  final String name;
  final String content;
  final String subject;
  final DateTime createdAt;

  Formula({
    required this.id,
    required this.name,
    required this.content,
    required this.subject,
    required this.createdAt,
  });

  factory Formula.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String createdAtString =
        data['createdAt'] as String? ?? DateTime.now().toIso8601String();

    return Formula(
      id: doc.id,
      name: data['name'] ?? '',
      content: data['content'] ?? '',
      subject: data['subject'] ?? '',
      // Chuyển đổi String thành DateTime
      createdAt: DateTime.parse(createdAtString),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'content': content,
      'subject': subject,
      // Chuyển đổi DateTime thành String (ISO 8601)
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
