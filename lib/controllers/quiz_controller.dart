import 'dart:async';
//import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/firestore_service.dart';
import '../services/database_helper.dart';

class QuizController {
  final QuizModel _model;
  final FirestoreService _firestoreService;
  final DatabaseHelper _databaseHelper;
  Timer? _timer;
  final Function() onStateChanged;

  QuizController(
    this._model,
    this._firestoreService,
    this._databaseHelper,
    this.onStateChanged,
  );

  Future<void> loadQuestions(String examId) async {
    try {
      final exam = await _firestoreService.getExamById(examId);
      if (exam != null) {
        final questions = await _firestoreService.getQuestionsByIds(
          exam.questionIDs,
        );
        _model.setQuestions(
          questions
              .map(
                (q) => {
                  'question': q.content,
                  'answers': q.options,
                  'correctAnswer': q.correctAnswer,
                },
              )
              .toList(),
        );
        _model.shuffleQuestions();
        _model.setLoading(false);
        startTimer();
      } else {
        _model.setError('Không tìm thấy bài kiểm tra');
      }
    } catch (e) {
      _model.setError(e.toString());
    }
    onStateChanged();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _model.updateTimer();
      if (_model.timeLeft <= 0) {
        _timer?.cancel();
        _model.nextQuestion();
      }
      onStateChanged();
    });
  }

  void selectAnswer(int index) {
    _model.selectAnswer(index);
    onStateChanged();
  }

  void goToQuestion(int index) {
    _model.goToQuestion(index);
    startTimer();
    onStateChanged();
  }

  void toggleQuestionList() {
    _model.toggleQuestionList();
    onStateChanged();
  }

  Future<void> finishQuiz(String subjectName, String examId) async {
    _timer?.cancel();
    final score = _model.calculateScore();
    final duration = _model.getDuration();

    await _databaseHelper.saveQuizHistory(
      subjectName: subjectName,
      examId: examId,
      score: score,
      totalQuestions: _model.questions.length,
      duration: duration.inSeconds,
      questions: _model.questions,
      answers: _model.userAnswers,
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
