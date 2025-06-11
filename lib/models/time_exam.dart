class TimeExam {
  final int? id;
  final String title;
  final String description;
  final DateTime examDate;

  TimeExam({
    this.id,
    required this.title,
    required this.description,
    required this.examDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'examDate': examDate.toIso8601String(),
    };
  }

  factory TimeExam.fromMap(Map<String, dynamic> map) {
    return TimeExam(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      examDate: DateTime.parse(map['examDate'] as String),
    );
  }

  TimeExam copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? examDate,
  }) {
    return TimeExam(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      examDate: examDate ?? this.examDate,
    );
  }
}
