class Reminder {
  final int? id;
  final String title;
  final String description;
  final DateTime time;
  final bool isActive;
  final String repeatType; // 'none', 'daily', 'weekly', 'monthly'
  final List<String>
  selectedDays; // ['monday', 'tuesday', ...] cho weekly repeat

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isActive = true,
    this.repeatType = 'none',
    this.selectedDays = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'repeatType': repeatType,
      'selectedDays': selectedDays.join(','),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      time: DateTime.parse(map['time']),
      isActive: map['isActive'] == 1,
      repeatType: map['repeatType'],
      selectedDays: map['selectedDays'].toString().split(','),
    );
  }
}
