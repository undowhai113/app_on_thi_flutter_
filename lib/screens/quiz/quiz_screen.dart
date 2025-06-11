import 'package:flutter/material.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/quiz_model.dart';
import '../../services/firestore_service.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String subjectName;
  final String groupName;
  final String examId;

  const QuizScreen({
    super.key,
    required this.subjectName,
    required this.groupName,
    required this.examId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizModel _model;
  late final QuizController _controller;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _model = QuizModel();
    _controller = QuizController(
      _model,
      _firestoreService,
      _databaseHelper,
      () => setState(() {}),
    );
    _controller.loadQuestions(widget.examId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} - Kiểm tra'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_model.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} - Kiểm tra'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã xảy ra lỗi: ${_model.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _controller.loadQuestions(widget.examId),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_model.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} - Kiểm tra'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Không có câu hỏi nào')),
      );
    }

    final currentQuestion = _model.questions[_model.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - Kiểm tra'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 20, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${_model.timeLeft}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(_model.showQuestionList ? Icons.close : Icons.list),
            onPressed: _controller.toggleQuestionList,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, AppTheme.backgroundColor],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LinearProgressIndicator(
                        value:
                            (_model.currentQuestionIndex + 1) /
                            _model.questions.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu ${_model.currentQuestionIndex + 1}/${_model.questions.length}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion['question'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(
                              currentQuestion['answers'].length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildAnswerCard(
                                  currentQuestion['answers'][index],
                                  index,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (_model.currentQuestionIndex > 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    () => _controller.goToQuestion(
                                      _model.currentQuestionIndex - 1,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Câu trước'),
                              ),
                            ),
                          if (_model.currentQuestionIndex > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _model.currentQuestionIndex <
                                          _model.questions.length - 1
                                      ? () => _controller.goToQuestion(
                                        _model.currentQuestionIndex + 1,
                                      )
                                      : () {
                                        _controller.finishQuiz(
                                          widget.subjectName,
                                          widget.examId,
                                        );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => QuizResultScreen(
                                                  subjectName:
                                                      widget.subjectName,
                                                  score:
                                                      _model.calculateScore(),
                                                  totalQuestions:
                                                      _model.questions.length,
                                                  questions: _model.questions,
                                                  userAnswers:
                                                      _model.userAnswers,
                                                ),
                                          ),
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _model.currentQuestionIndex <
                                        _model.questions.length - 1
                                    ? 'Câu tiếp theo'
                                    : 'Kết thúc',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_model.showQuestionList)
            Container(
              width: 80,
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: _model.questions.length,
                itemBuilder: (context, index) {
                  final isAnswered = _model.userAnswers[index] != null;

                  return InkWell(
                    onTap: () => _controller.goToQuestion(index),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            index == _model.currentQuestionIndex
                                ? AppTheme.primaryColor
                                : isAnswered
                                ? Colors.blue
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              index == _model.currentQuestionIndex
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                index == _model.currentQuestionIndex
                                    ? Colors.white
                                    : isAnswered
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(String answer, int index) {
    final isSelected = _model.userAnswers[_model.currentQuestionIndex] == index;
    Color? backgroundColor;
    Color? borderColor;

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
      borderColor = AppTheme.primaryColor;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor ?? Colors.grey[300]!, width: 2),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: () => _controller.selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: borderColor ?? Colors.grey[400],
                            ),
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
