import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String title;
  final String subject;
  final List<String> questionIDs;
  final int? duration; // Giữ nguyên kiểu int? cho duration
  final String? description; // Giữ nguyên kiểu String? cho description
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.title,
    required this.subject,
    required this.questionIDs,
    this.duration,
    this.description,
    required this.createdAt,
  });

  factory Exam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Đọc createdAt là String, có giá trị mặc định nếu null hoặc không phải String
    String createdAtString =
        data['createdAt'] as String? ?? DateTime.now().toIso8601String();

    return Exam(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      questionIDs: List<String>.from(data['questionIDs'] ?? []),
      duration: data['duration'] as int?, // Ép kiểu sang int? nếu cần
      description:
          data['description'] as String?, // Ép kiểu sang String? nếu cần
      // Chuyển đổi String thành DateTime
      createdAt: DateTime.parse(createdAtString),
    );
  }

  // Sửa ở đây để ghi DateTime thành String (ISO 8601) lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'questionIDs': questionIDs,
      'duration': duration,
      'description': description,
      // Chuyển đổi DateTime thành String (ISO 8601)
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
