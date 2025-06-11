import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../models/formula.dart';
import '../models/question.dart';
import '../models/exam.dart';
import '../services/firestore_service.dart';

class StudyProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Document> _documents = [];
  List<Formula> _formulas = [];
  List<Question> _questions = [];
  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Document> get documents => _documents;
  List<Formula> get formulas => _formulas;
  List<Question> get questions => _questions;
  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load documents by subject
  Future<void> loadDocuments(String subject) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    try {
      final documents = await _firestoreService.getDocumentsBySubject(subject);
      _documents = documents;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load formulas by subject
  Future<void> loadFormulas(String subject) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    try {
      final formulas = await _firestoreService.getFormulasBySubject(subject);
      _formulas = formulas;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load questions by subject
  Future<void> loadQuestions(String subject) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _firestoreService.getQuestionsBySubject(subject);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load exams by subject
  Future<void> loadExams(String subject) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    try {
      final exams = await _firestoreService.getExamsBySubject(subject);
      _exams = exams;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get questions for an exam
  Future<List<Question>> getExamQuestions(String examId) async {
    _isLoading = true;
    _error = null;
    //notifyListeners();

    try {
      final exam = await _firestoreService.getExamById(examId);
      if (exam != null) {
        return await _firestoreService.getQuestionsByIds(exam.questionIDs);
      }
      return [];
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new document
  Future<String?> createDocument(Document document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.createDocument(document);
      _documents.add(document);
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new formula
  Future<String?> createFormula(Formula formula) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.createFormula(formula);
      _formulas.add(formula);
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new question
  Future<String?> createQuestion(Question question) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.createQuestion(question);
      _questions.add(question);
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new exam
  Future<String?> createExam(Exam exam) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _firestoreService.createExam(exam);
      _exams.add(exam);
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
