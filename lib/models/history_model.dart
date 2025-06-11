class HistoryModel {
  List<Map<String, dynamic>> _quizHistory = [];
  List<Map<String, dynamic>> _practiceHistory = [];
  bool _isLoading = true;
  String? _error;
  bool _showQuizHistory = true;
  bool _showPracticeHistory = false;

  // Getters
  List<Map<String, dynamic>> get quizHistory => _quizHistory;
  List<Map<String, dynamic>> get practiceHistory => _practiceHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showQuizHistory => _showQuizHistory;
  bool get showPracticeHistory => _showPracticeHistory;

  // Setters
  void setQuizHistory(List<Map<String, dynamic>> history) {
    _quizHistory = history;
  }

  void setPracticeHistory(List<Map<String, dynamic>> history) {
    _practiceHistory = history;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _error = error;
  }

  // Methods
  void toggleQuizHistory() {
    _showQuizHistory = !_showQuizHistory;
    if (_showQuizHistory) {
      _showPracticeHistory = false;
    }
  }

  void togglePracticeHistory() {
    _showPracticeHistory = !_showPracticeHistory;
    if (_showPracticeHistory) {
      _showQuizHistory = false;
    }
  }
}
