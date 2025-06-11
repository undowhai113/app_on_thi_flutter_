import 'package:flutter/material.dart';
import '../models/formula.dart';
import '../services/firestore_service.dart';

class FormulaController {
  final FirestoreService _firestoreService;
  final Function() onStateChanged;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<Formula> _formulas = [];
  List<Formula> _filteredFormulas = [];
  bool _isLoading = true;
  String? _error;

  FormulaController(this._firestoreService, this.onStateChanged) {
    searchController.addListener(_onSearchChanged);
  }

  String get searchQuery => _searchQuery;
  List<Formula> get formulas => _filteredFormulas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _onSearchChanged() {
    _searchQuery = searchController.text;
    _filterFormulas();
    onStateChanged();
  }

  Future<void> loadFormulas(String subjectName) async {
    try {
      _isLoading = true;
      _error = null;
      onStateChanged();

      final formulas = await _firestoreService.getFormulasBySubject(
        subjectName,
      );
      _formulas = formulas;
      _filterFormulas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      onStateChanged();
    }
  }

  void _filterFormulas() {
    if (_searchQuery.isEmpty) {
      _filteredFormulas = _formulas;
    } else {
      _filteredFormulas =
          _formulas.where((formula) {
            final name = formula.name.toLowerCase();
            final searchLower = _searchQuery.toLowerCase();
            return name.contains(searchLower);
          }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _filterFormulas();
    onStateChanged();
  }

  void dispose() {
    searchController.dispose();
  }
}
