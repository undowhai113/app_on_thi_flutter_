import 'package:flutter/material.dart';
import '../../controllers/practice_controller.dart';
import '../../models/practice_model.dart';
import '../../services/firestore_service.dart';
import '../../services/database_helper.dart';
import '../../theme/app_theme.dart';
import 'quiz_result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final String subjectName;
  final String groupName;

  const PracticeScreen({
    super.key,
    required this.subjectName,
    required this.groupName,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late PracticeModel _model;
  late PracticeController _controller;
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _showQuestionList = false;

  @override
  void initState() {
    super.initState();
    _model = PracticeModel();
    _controller = PracticeController(
      _model,
      _firestoreService,
      _databaseHelper,
      () {
        if (mounted) {
          setState(() {});
        }
      },
    );
    _controller.loadQuestions(widget.subjectName);
  }

  @override
  void dispose() {
    _controller.saveProgress();
    super.dispose();
  }

  void _finishPractice() async {
    try {
      final result = await _controller.finishPractice(widget.subjectName);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizResultScreen(
                  subjectName: widget.subjectName,
                  score: result['score'] as int,
                  totalQuestions: result['totalQuestions'] as int,
                  questions: result['questions'] as List<Map<String, dynamic>>,
                  userAnswers: result['userAnswers'] as List<int?>,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi kết thúc bài ôn tập'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} - Ôn tập'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_model.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} - Ôn tập'),
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
                onPressed: () => _controller.loadQuestions(widget.subjectName),
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
          title: Text('${widget.subjectName} - Ôn tập'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Không có câu hỏi nào')),
      );
    }

    final currentQuestion = _model.questions[_model.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - Ôn tập'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showQuestionList ? Icons.close : Icons.list),
            onPressed: () {
              setState(() {
                _showQuestionList = !_showQuestionList;
              });
            },
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
                            (_model.userAnswers
                                .where((a) => a != null)
                                .length) /
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
                                  currentQuestion['correctAnswer'],
                                ),
                              ),
                            ),
                            if (currentQuestion['explanation'] != null &&
                                _model.isAnswered)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Giải thích:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currentQuestion['explanation'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
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
                                        _finishPractice();
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
          if (_showQuestionList)
            Container(
              width: 80,
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: _model.questions.length,
                itemBuilder: (context, index) {
                  final isAnswered = _model.userAnswers[index] != null;
                  final isCorrect =
                      isAnswered &&
                      _model.userAnswers[index] ==
                          _model.questions[index]['correctAnswer'];

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
                                ? (isCorrect ? Colors.green : Colors.red)
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

  Widget _buildAnswerCard(String answer, int index, int correctAnswer) {
    final isSelected = _model.selectedAnswerIndex == index;
    final isCorrect = index == correctAnswer;
    Color? backgroundColor;
    Color? borderColor;

    if (_model.isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
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
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _model.isAnswered && isCorrect
                            ? Colors.green
                            : _model.isAnswered && isSelected
                            ? Colors.red
                            : null,
                  ),
                ),
              ),
              if (_model.isAnswered && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (_model.isAnswered && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
