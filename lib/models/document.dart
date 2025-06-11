import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String title;
  final String content;
  final String subject;
  final String category;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.title,
    required this.content,
    required this.subject,
    required this.category,
    required this.createdAt,
  });

  factory Document.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String createdAtString =
        data['createdAt'] as String? ??
        DateTime.now()
            .toIso8601String(); // Lấy ra là String, có giá trị mặc định nếu null

    return Document(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      subject: data['subject'] ?? '',
      category: data['category'] ?? '',
      // Chuyển đổi String thành DateTime
      createdAt: DateTime.parse(createdAtString),
    );
  }

  // ghi DateTime thành String (ISO 8601) lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'subject': subject,
      'category': category,
      // Chuyển đổi DateTime thành String (ISO 8601)
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
