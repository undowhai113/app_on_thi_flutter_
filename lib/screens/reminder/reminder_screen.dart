import 'package:flutter/material.dart';
import '../../models/reminder.dart';
import '../../controllers/reminder_controller.dart';
import '../../theme/app_theme.dart';
//import '../../widgets/reminder_overlay.dart';
import 'add_reminder_screen.dart';
import 'dart:async';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;
  late ReminderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReminderController(context, () => setState(() {}));
    _loadReminders();
  }

  @override
  void dispose() {
    _controller.stopCheckingReminders();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      _reminders = await _controller.loadReminders();
      _controller.startCheckingReminders(_reminders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải nhắc nhở: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa nhắc nhở "${reminder.title}"?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _controller.deleteReminder(reminder);
      _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắc nhở'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reminders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có nhắc nhở nào',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Dismissible(
                    key: Key(reminder.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => _confirmDelete(reminder),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              reminder.isActive
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.grey[200]!,
                              reminder.isActive
                                  ? AppTheme.primaryColor.withOpacity(0.05)
                                  : Colors.grey[100]!,
                            ],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            reminder.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                reminder.description,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reminder.time.day}/${reminder.time.month}/${reminder.time.year}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              if (reminder.repeatType != 'none') ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.repeat,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reminder.repeatType == 'daily'
                                          ? 'Hàng ngày'
                                          : reminder.repeatType == 'weekly'
                                          ? 'Hàng tuần'
                                          : 'Hàng tháng',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Switch(
                            value: reminder.isActive,
                            onChanged: (value) async {
                              await _controller.saveReminder(
                                id: reminder.id,
                                title: reminder.title,
                                description: reminder.description,
                                time: reminder.time,
                                repeatType: reminder.repeatType,
                                selectedDays: reminder.selectedDays,
                                isActive: value,
                              );
                              _loadReminders();
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddReminderScreen(reminder: reminder),
                              ),
                            );
                            if (result == true) {
                              _loadReminders();
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
          if (result == true) {
            _loadReminders();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
