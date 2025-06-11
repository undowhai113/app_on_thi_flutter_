import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/reminder_database.dart';
import '../widgets/reminder_overlay.dart';
import 'dart:async';

class ReminderController {
  final Function() onStateChanged;
  final BuildContext context;
  final Set<int> _shownReminders = {};
  Timer? _timer;

  ReminderController(this.context, this.onStateChanged);

  void startCheckingReminders(List<Reminder> reminders) {
    // Kiểm tra mỗi phút
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      checkReminders(reminders);
    });
  }

  void stopCheckingReminders() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<Reminder>> loadReminders() async {
    try {
      final reminders = await ReminderDatabase.instance.getAllReminders();
      checkReminders(reminders);
      return reminders;
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      rethrow;
    }
  }

  void checkReminders(List<Reminder> reminders) {
    final now = DateTime.now();
    for (final reminder in reminders) {
      if (!reminder.isActive) continue;

      final reminderTime = reminder.time;
      final isTimeMatch =
          reminderTime.hour == now.hour && reminderTime.minute == now.minute;

      if (isTimeMatch && !_shownReminders.contains(reminder.id)) {
        ReminderOverlay.show(context, reminder);
        _shownReminders.add(reminder.id!);

        // Xóa reminder khỏi danh sách đã hiển thị sau 1 phút
        Future.delayed(const Duration(minutes: 1), () {
          _shownReminders.remove(reminder.id);
        });
      }
    }
  }

  Future<bool> deleteReminder(Reminder reminder) async {
    try {
      await ReminderDatabase.instance.deleteReminder(reminder.id!);
      onStateChanged();
      return true;
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa nhắc nhở'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> saveReminder({
    int? id,
    required String title,
    required String description,
    required DateTime time,
    required String repeatType,
    required List<String> selectedDays,
    bool isActive = true,
  }) async {
    try {
      final reminder = Reminder(
        id: id,
        title: title,
        description: description,
        time: time,
        isActive: isActive,
        repeatType: repeatType,
        selectedDays: selectedDays,
      );

      if (id == null) {
        await ReminderDatabase.instance.createReminder(reminder);
      } else {
        await ReminderDatabase.instance.updateReminder(reminder);
      }
      onStateChanged();
    } catch (e) {
      debugPrint('Error saving reminder: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu nhắc nhở'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<TimeOfDay?> selectTime(DateTime initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );
  }

  Future<DateTime?> selectDate(DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  Future<List<String>> showDaySelector(List<String> selectedDays) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chọn các ngày trong tuần',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Thứ 2',
                          'Thứ 3',
                          'Thứ 4',
                          'Thứ 5',
                          'Thứ 6',
                          'Thứ 7',
                          'Chủ nhật',
                        ].map((day) {
                          final isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, selectedDays),
                    child: const Text('Xong'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return result ?? selectedDays;
  }
}
