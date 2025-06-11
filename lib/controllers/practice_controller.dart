//import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/practice_model.dart';
import '../services/firestore_service.dart';
import '../services/database_helper.dart';

class PracticeController {
  final PracticeModel _model;
  final FirestoreService _firestoreService;
  final DatabaseHelper _databaseHelper;
  final Function() onStateChanged;
  String? _subjectName;

  PracticeController(
    this._model,
    this._firestoreService,
    this._databaseHelper,
    this.onStateChanged,
  );

  Future<void> loadQuestions(String subjectName) async {
    try {
      _subjectName = subjectName;
      _model.setLoading(true);
      onStateChanged();

      final questions = await _firestoreService.getQuestionsBySubject(
        subjectName,
      );

      if (questions.isEmpty) {
        _model.setError('Chưa có câu hỏi nào cho môn học này');
        return;
      }

      _model.setQuestions(
        questions
            .map(
              (q) => {
                'question': q.content,
                'answers': q.options,
                'correctAnswer': q.correctAnswer,
                'explanation': q.explanation,
              },
            )
            .toList(),
      );
      await loadProgress(subjectName);
    } catch (e) {
      _model.setError(e.toString());
    } finally {
      _model.setLoading(false);
      onStateChanged();
    }
  }

  Future<void> loadProgress(String subjectName) async {
    final progress = await _databaseHelper.getProgress(subjectName);
    if (progress != null) {
      _model.goToQuestion(progress['questionIndex'] as int);
      final savedAnswers = progress['userAnswers'] as String?;
      if (savedAnswers != null) {
        final List<dynamic> decodedAnswers = jsonDecode(savedAnswers);
        for (int i = 0; i < decodedAnswers.length; i++) {
          if (decodedAnswers[i] != null) {
            _model.userAnswers[i] = decodedAnswers[i] as int;
          }
        }
      }
    }
    onStateChanged();
  }

  void selectAnswer(int index) {
    _model.selectAnswer(index);
    saveProgress();
    onStateChanged();
  }

  void goToQuestion(int index) {
    _model.goToQuestion(index);
    saveProgress();
    onStateChanged();
  }

  void toggleQuestionList() {
    _model.toggleQuestionList();
    onStateChanged();
  }

  Future<void> saveProgress() async {
    if (_subjectName != null && _model.questions.isNotEmpty) {
      await _databaseHelper.saveProgress(
        subjectName: _subjectName!,
        questionIndex: _model.currentQuestionIndex,
        userAnswer: _model.userAnswers[_model.currentQuestionIndex],
        userAnswers: jsonEncode(_model.userAnswers),
      );
    }
  }

  Future<Map<String, dynamic>> finishPractice(String subjectName) async {
    try {
      // Tính điểm
      int score = 0;
      for (int i = 0; i < _model.questions.length; i++) {
        if (_model.userAnswers[i] != null &&
            _model.userAnswers[i] == _model.questions[i]['correctAnswer']) {
          score++;
        }
      }

      // Lưu lại câu trả lời trước khi xóa tiến trình
      final savedAnswers = List<int?>.from(_model.userAnswers);

      // Xóa tiến trình
      await _databaseHelper.deleteProgress(subjectName);

      // Lưu lịch sử
      await _databaseHelper.savePracticeHistory(
        subjectName: subjectName,
        score: score,
        totalQuestions: _model.questions.length,
        duration: _model.getDuration(),
        answers: savedAnswers,
      );

      // Reset state
      _model.resetPractice();

      // Trả về kết quả để hiển thị màn hình kết quả
      return {
        'score': score,
        'totalQuestions': _model.questions.length,
        'questions': _model.questions,
        'userAnswers': savedAnswers,
      };
    } catch (e) {
      _model.setError(e.toString());
      rethrow;
    }
  }

  void resetPractice() {
    _model.resetPractice();
    onStateChanged();
  }
}
