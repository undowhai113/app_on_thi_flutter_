//import 'package:flutter/material.dart';

class QuizModel {
  List<Map<String, dynamic>> _questions = [];
  List<int?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int _timeLeft = 0;
  bool _isLoading = true;
  String? _error;
  bool _showQuestionList = false;

  // Getters
  List<Map<String, dynamic>> get questions => _questions;
  List<int?> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get timeLeft => _timeLeft;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showQuestionList => _showQuestionList;

  // Setters
  void setQuestions(List<Map<String, dynamic>> questions) {
    _questions = questions;
    _userAnswers = List.filled(questions.length, null);
    _timeLeft = 60; // 60 seconds per question
  }

  void shuffleQuestions() {
    _questions.shuffle();
    _userAnswers = List.filled(_questions.length, null);
    _currentQuestionIndex = 0;
    _timeLeft = 60;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _error = error;
  }

  // Methods
  void selectAnswer(int index) {
    _userAnswers[_currentQuestionIndex] = index;
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _timeLeft = 60;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      _timeLeft = 60;
    }
  }

  void updateTimer() {
    if (_timeLeft > 0) {
      _timeLeft--;
    }
  }

  void toggleQuestionList() {
    _showQuestionList = !_showQuestionList;
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswer']) {
        score++;
      }
    }
    return score;
  }

  Duration getDuration() {
    return Duration(minutes: _questions.length);
  }
}
