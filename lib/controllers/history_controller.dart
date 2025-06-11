//import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/database_helper.dart';

class HistoryController {
  final HistoryModel _model;
  final DatabaseHelper _databaseHelper;
  final Function() onStateChanged;

  HistoryController(this._model, this._databaseHelper, this.onStateChanged);

  Future<void> loadHistory() async {
    try {
      _model.setLoading(true);
      onStateChanged();

      final history = await _databaseHelper.getQuizHistory();
      _model.setQuizHistory(history);
    } catch (e) {
      _model.setError(e.toString());
    } finally {
      _model.setLoading(false);
      onStateChanged();
    }
  }

  Future<void> deleteHistory(int id) async {
    try {
      await _databaseHelper.deleteQuizHistory(id);
      await loadHistory(); // Reload history after deletion
    } catch (e) {
      _model.setError(e.toString());
      onStateChanged();
    }
  }

  Future<void> deleteQuizHistory(int id) async {
    try {
      await _databaseHelper.deleteQuizHistory(id);
      await loadHistory();
    } catch (e) {
      _model.setError(e.toString());
    }
    onStateChanged();
  }

  Future<void> deletePracticeHistory(int id) async {
    try {
      await _databaseHelper.deletePracticeHistory(id);
      await loadHistory();
    } catch (e) {
      _model.setError(e.toString());
    }
    onStateChanged();
  }

  void toggleQuizHistory() {
    _model.toggleQuizHistory();
    onStateChanged();
  }

  void togglePracticeHistory() {
    _model.togglePracticeHistory();
    onStateChanged();
  }
}
