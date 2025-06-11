//import 'package:flutter/material.dart';

class PracticeModel {
  List<Map<String, dynamic>> _questions = [];
  List<int?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _showQuestionList = false;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  DateTime _startTime = DateTime.now();

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  List<int?> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showQuestionList => _showQuestionList;
  bool get isAnswered => _isAnswered;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

  // Setters
  void setQuestions(List<Map<String, dynamic>> questions) {
    _questions = questions;
    _userAnswers = List.filled(questions.length, null);
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _error = error;
  }

  // Methods
  void selectAnswer(int index) {
    _selectedAnswerIndex = index;
    _userAnswers[_currentQuestionIndex] = index;
    _isAnswered = true;
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      _selectedAnswerIndex = _userAnswers[index];
      _isAnswered = _userAnswers[index] != null;
    }
  }

  void toggleQuestionList() {
    _showQuestionList = !_showQuestionList;
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] != null &&
          _userAnswers[i] == _questions[i]['correctAnswer']) {
        score++;
      }
    }
    return score;
  }

  Duration getDuration() {
    return DateTime.now().difference(_startTime);
  }

  void resetPractice() {
    _currentQuestionIndex = 0;
    _userAnswers = List.filled(_questions.length, null);
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _startTime = DateTime.now();
  }
}
