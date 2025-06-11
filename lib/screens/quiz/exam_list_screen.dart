import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../theme/app_theme.dart';
import 'quiz_screen.dart';

class ExamListScreen extends StatefulWidget {
  final String subjectName;

  const ExamListScreen({super.key, required this.subjectName});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  Future<void>? _loadExamsFuture;

  @override
  void initState() {
    super.initState();
    _loadExamsFuture = context.read<StudyProvider>().loadExams(
      widget.subjectName,
    );
  }

  Future<void> _retryLoading() async {
    setState(() {
      _loadExamsFuture = context.read<StudyProvider>().loadExams(
        widget.subjectName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - Đề kiểm tra'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.backgroundColor],
          ),
        ),
        child: FutureBuilder(
          future: _loadExamsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã xảy ra lỗi: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryLoading,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return Consumer<StudyProvider>(
              builder: (context, studyProvider, child) {
                if (studyProvider.exams.isEmpty) {
                  return const Center(child: Text('Chưa có đề kiểm tra nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: studyProvider.exams.length,
                  itemBuilder: (context, index) {
                    final exam = studyProvider.exams[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => QuizScreen(
                                    subjectName: widget.subjectName,
                                    groupName: exam.title,
                                    examId: exam.id,
                                  ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (exam.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  exam.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.timer,
                                    '${exam.duration ?? 60} phút',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.help_outline,
                                    '${exam.questionIDs.length} câu hỏi',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
