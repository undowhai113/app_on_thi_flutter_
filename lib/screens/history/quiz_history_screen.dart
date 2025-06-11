import 'package:flutter/material.dart';
import '../../controllers/history_controller.dart';
import '../../models/history_model.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';
import '../quiz/quiz_result_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late final HistoryModel _model;
  late final HistoryController _controller;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _model = HistoryModel();
    _controller = HistoryController(
      _model,
      _databaseHelper,
      () => setState(() {}),
    );
    _controller.loadHistory();
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getScoreColor(int score, int total) {
    final percentage = score / total;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> history) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa bài kiểm tra ${history['subjectName']}?',
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
      await _controller.deleteHistory(history['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài kiểm tra'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _viewQuizDetails(Map<String, dynamic> history) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizResultScreen(
              subjectName: history['subjectName'],
              score: history['score'],
              totalQuestions: history['totalQuestions'],
              questions: history['questions'],
              userAnswers: history['answers'],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử làm bài'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _databaseHelper.resetDatabase();
              await _controller.loadHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã reset cơ sở dữ liệu thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            tooltip: 'Reset database',
          ),
        ],
      ),
      body:
          _model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _model.quizHistory.isEmpty
              ? const Center(
                child: Text(
                  'Chưa có lịch sử làm bài',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _model.quizHistory.length,
                itemBuilder: (context, index) {
                  final history = _model.quizHistory[index];
                  final score = history['score'] as int;
                  final total = history['totalQuestions'] as int;
                  final scoreColor = _getScoreColor(score, total);

                  return Dismissible(
                    key: Key(history['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed:
                        (direction) => _showDeleteConfirmation(history),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _viewQuizDetails(history),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [scoreColor.withOpacity(0.7), scoreColor],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      history['subjectName'] as String,
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
                                      '${(score / total * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoItem(
                                    Icons.timer,
                                    _formatDuration(history['duration'] as int),
                                  ),
                                  _buildInfoItem(
                                    Icons.calendar_today,
                                    _formatDate(history['date'] as String),
                                  ),
                                  _buildInfoItem(
                                    Icons.check_circle,
                                    '$score/$total câu đúng',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
