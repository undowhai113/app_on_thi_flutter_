import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
//import '../../models/formula.dart';
import '../../controllers/formula_controller.dart';
import 'formula_detail_screen.dart';

class FormulaListScreen extends StatefulWidget {
  final String subjectName;
  final String groupName;

  const FormulaListScreen({
    super.key,
    required this.subjectName,
    required this.groupName,
  });

  @override
  State<FormulaListScreen> createState() => _FormulaListScreenState();
}

class _FormulaListScreenState extends State<FormulaListScreen> {
  late final FormulaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormulaController(FirestoreService(), () => setState(() {}));
    _controller.loadFormulas(widget.subjectName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Công thức - ${widget.subjectName}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã xảy ra lỗi: ${_controller.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _controller.loadFormulas(widget.subjectName),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppTheme.backgroundColor],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công thức...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon:
                      _controller.searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _controller.clearSearch,
                          )
                          : null,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _controller.formulas.isEmpty
                    ? const Center(
                      child: Text(
                        'Không tìm thấy công thức nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _controller.formulas.length,
                      itemBuilder: (context, index) {
                        final formula = _controller.formulas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          FormulaDetailScreen(formula: formula),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formula.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formula.content,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'monospace',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
