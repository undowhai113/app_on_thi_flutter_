//import 'package:flutter/material.dart';
import 'dart:async';
import '../models/time_exam.dart';
import '../services/time_exam_database.dart';

class CountdownController {
  final TimeExamDatabase _database = TimeExamDatabase.instance;
  List<TimeExam> _exams = [];
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  final _onTick = StreamController<void>.broadcast();

  // Getters
  List<TimeExam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<void> get onTick => _onTick.stream;

  // Initialize timer
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick.add(null);
    });
  }

  // Dispose timer
  void dispose() {
    _timer?.cancel();
    _onTick.close();
  }

  // Load exams
  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    try {
      _exams = await _database.getAllTimeExams();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  // Delete exam
  Future<bool> deleteExam(TimeExam exam) async {
    try {
      await _database.deleteTimeExam(exam.id!);
      await loadExams();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Update exam
  Future<bool> updateExam(TimeExam exam, Map<String, dynamic> updates) async {
    try {
      final updatedExam = exam.copyWith(
        title: updates['title'],
        description: updates['description'],
        examDate: updates['date'],
      );
      await _database.updateTimeExam(updatedExam);
      await loadExams();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Calculate time remaining
  Map<String, dynamic> getTimeRemaining(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);

    if (difference.isNegative) {
      return {
        'days': 0,
        'hours': 0,
        'minutes': 0,
        'seconds': 0,
        'isOverdue': true,
      };
    }

    return {
      'days': difference.inDays,
      'hours': difference.inHours.remainder(24),
      'minutes': difference.inMinutes.remainder(60),
      'seconds': difference.inSeconds.remainder(60),
      'isOverdue': false,
    };
  }

  // Create exam
  Future<bool> createExam(Map<String, dynamic> examData) async {
    try {
      final exam = TimeExam(
        title: examData['title'],
        description: examData['description'],
        examDate: examData['date'],
      );
      await _database.createTimeExam(exam);
      await loadExams();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
