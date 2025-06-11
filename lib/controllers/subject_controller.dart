//import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/firestore_service.dart';

class SubjectController {
  final SubjectModel _model;
  final FirestoreService _firestoreService;
  final Function() onStateChanged;

  SubjectController(this._model, this._firestoreService, this.onStateChanged);

  Future<void> loadSubjects() async {
    try {
      final subjects = await _firestoreService.getSubjects();
      _model.setSubjects(subjects);
      _model.setLoading(false);
    } catch (e) {
      _model.setError(e.toString());
    }
    onStateChanged();
  }

  Future<void> loadExams(String subjectId) async {
    try {
      final exams = await _firestoreService.getExamsBySubject(subjectId);
      _model.setExams(
        exams
            .map(
              (exam) => {
                'id': exam.id,
                'title': exam.title,
                'description': exam.description,
                'duration': exam.duration,
                'questionIDs': exam.questionIDs,
              },
            )
            .toList(),
      );
      _model.setLoading(false);
    } catch (e) {
      _model.setError(e.toString());
    }
    onStateChanged();
  }

  void selectSubject(String subjectId) {
    _model.selectSubject(subjectId);
    onStateChanged();
  }

  void selectExam(String examId) {
    _model.selectExam(examId);
    onStateChanged();
  }

  void toggleExamList() {
    _model.toggleExamList();
    onStateChanged();
  }
}
