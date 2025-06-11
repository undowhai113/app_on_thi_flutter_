import 'package:flutter/material.dart';
import '../../models/reminder.dart';
import '../../controllers/reminder_controller.dart';
import '../../theme/app_theme.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedTime;
  String _repeatType = 'none';
  List<String> _selectedDays = [];
  late ReminderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReminderController(context, () => setState(() {}));
    _selectedTime = widget.reminder?.time ?? DateTime.now();
    _titleController.text = widget.reminder?.title ?? '';
    _descriptionController.text = widget.reminder?.description ?? '';
    _repeatType = widget.reminder?.repeatType ?? 'none';
    _selectedDays = widget.reminder?.selectedDays ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await _controller.selectTime(_selectedTime);
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await _controller.selectDate(_selectedTime);
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _showDaySelector() async {
    final result = await _controller.showDaySelector(_selectedDays);
    setState(() {
      _selectedDays = result;
    });
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      await _controller.saveReminder(
        id: widget.reminder?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        time: _selectedTime,
        repeatType: _repeatType,
        selectedDays: _selectedDays,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminder == null ? 'Thêm nhắc nhở' : 'Chỉnh sửa nhắc nhở',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mô tả';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedTime.day}/${_selectedTime.month}/${_selectedTime.year}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _repeatType,
              decoration: const InputDecoration(
                labelText: 'Lặp lại',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Không lặp lại')),
                DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
              ],
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                  if (value != 'weekly') {
                    _selectedDays = [];
                  }
                });
              },
            ),
            if (_repeatType == 'weekly') ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showDaySelector,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedDays.isEmpty
                      ? 'Chọn các ngày trong tuần'
                      : _selectedDays.join(', '),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.reminder == null ? 'Thêm nhắc nhở' : 'Cập nhật nhắc nhở',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
