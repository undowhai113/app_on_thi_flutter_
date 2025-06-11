import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = true;
  List<Map<String, dynamic>> _progressList = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);

    // Danh sách các môn học
    final subjects = ['Toán', 'Lý', 'Hóa', 'Sinh', 'Anh', 'Văn', 'Sử', 'Địa'];

    List<Map<String, dynamic>> progress = [];
    for (final subject in subjects) {
      final data = await _databaseHelper.getProgress(subject);
      if (data != null) {
        progress.add({
          'subjectName': subject,
          'questionIndex': data['questionIndex'] as int,
          'isCompleted': data['isCompleted'] == 1,
        });
      } else {
        progress.add({
          'subjectName': subject,
          'questionIndex': 0,
          'isCompleted': false,
        });
      }
    }

    setState(() {
      _progressList = progress;
      _isLoading = false;
    });
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Toán':
        return const Color(0xFF2196F3); // Blue
      case 'Lý':
        return const Color(0xFF9C27B0); // Purple
      case 'Hóa':
        return const Color(0xFF4CAF50); // Green
      case 'Sinh':
        return const Color(0xFFE91E63); // Pink
      case 'Anh':
        return const Color(0xFFFF9800); // Orange
      case 'Văn':
        return const Color(0xFF795548); // Brown
      case 'Sử':
        return const Color(0xFF607D8B); // Blue Grey
      case 'Địa':
        return const Color(0xFF009688); // Teal
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Toán':
        return Icons.calculate;
      case 'Lý':
        return Icons.science;
      case 'Hóa':
        return Icons.science_outlined;
      case 'Sinh':
        return Icons.biotech;
      case 'Anh':
        return Icons.language;
      case 'Văn':
        return Icons.menu_book;
      case 'Sử':
        return Icons.history_edu;
      case 'Địa':
        return Icons.public;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ học tập'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProgressList(),
    );
  }

  Widget _buildProgressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _progressList.length,
      itemBuilder: (context, index) {
        final progress = _progressList[index];
        final subjectName = progress['subjectName'] as String;
        final questionIndex = progress['questionIndex'] as int;
        final isCompleted = progress['isCompleted'] as bool;
        final color = _getSubjectColor(subjectName);
        final icon = _getSubjectIcon(subjectName);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subjectName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompleted ? 'Hoàn thành' : 'Đang học',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1.0 : questionIndex / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCompleted
                      ? 'Đã hoàn thành 100%'
                      : 'Đã hoàn thành ${(questionIndex / 100 * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
