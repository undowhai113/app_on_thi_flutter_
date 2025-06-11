import 'package:flutter/material.dart';
import '../models/document.dart';
import '../providers/study_provider.dart';

class TheoryController {
  final StudyProvider _studyProvider;
  final Function() onStateChanged;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<Document> _filteredDocuments = [];

  TheoryController(this._studyProvider, this.onStateChanged) {
    searchController.addListener(_onSearchChanged);
  }

  String get searchQuery => _searchQuery;
  List<Document> get filteredDocuments => _filteredDocuments;

  void _onSearchChanged() {
    _searchQuery = searchController.text;
    _filterDocuments();
    onStateChanged();
  }

  Future<void> loadDocuments(String subjectName) async {
    try {
      await _studyProvider.loadDocuments(subjectName);
      _filterDocuments();
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  void _filterDocuments() {
    final documents = _studyProvider.documents;
    if (_searchQuery.isEmpty) {
      _filteredDocuments = documents;
    } else {
      _filteredDocuments =
          documents.where((doc) {
            final title = doc.title.toLowerCase();
            final searchLower = _searchQuery.toLowerCase();
            return title.contains(searchLower);
          }).toList();
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _filterDocuments();
    onStateChanged();
  }

  void dispose() {
    searchController.dispose();
  }
}
