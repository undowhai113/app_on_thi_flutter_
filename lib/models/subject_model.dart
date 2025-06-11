class SubjectModel {
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _exams = [];
  String? _selectedSubjectId;
  String? _selectedExamId;
  bool _isLoading = true;
  String? _error;
  bool _showExamList = false;

  // Getters
  List<Map<String, dynamic>> get subjects => _subjects;
  List<Map<String, dynamic>> get exams => _exams;
  String? get selectedSubjectId => _selectedSubjectId;
  String? get selectedExamId => _selectedExamId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showExamList => _showExamList;

  // Setters
  void setSubjects(List<Map<String, dynamic>> subjects) {
    _subjects = subjects;
  }

  void setExams(List<Map<String, dynamic>> exams) {
    _exams = exams;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _error = error;
  }

  // Methods
  void selectSubject(String subjectId) {
    _selectedSubjectId = subjectId;
    _selectedExamId = null;
    _exams = [];
  }

  void selectExam(String examId) {
    _selectedExamId = examId;
  }

  void toggleExamList() {
    _showExamList = !_showExamList;
  }
}
