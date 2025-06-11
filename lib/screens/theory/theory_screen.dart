import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../theme/app_theme.dart';
import '../../controllers/theory_controller.dart';
import 'document_detail_screen.dart';

class TheoryScreen extends StatefulWidget {
  final String subjectName;
  final String groupName;

  const TheoryScreen({
    super.key,
    required this.subjectName,
    required this.groupName,
  });

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  late final TheoryController _controller;
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    final studyProvider = context.read<StudyProvider>();
    _controller = TheoryController(studyProvider, () => setState(() {}));
    _loadDataFuture = _controller.loadDocuments(widget.subjectName);
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
        title: Text('${widget.subjectName} - Lý thuyết'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã xảy ra lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadDataFuture = _controller.loadDocuments(
                          widget.subjectName,
                        );
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Consumer<StudyProvider>(
            builder: (context, studyProvider, child) {
              if (studyProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã xảy ra lỗi: ${studyProvider.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadDataFuture = _controller.loadDocuments(
                              widget.subjectName,
                            );
                          });
                        },
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
                            hintText: 'Tìm kiếm theo tiêu đề...',
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
                          _controller.filteredDocuments.isEmpty
                              ? const Center(
                                child: Text(
                                  'Không tìm thấy tài liệu nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _controller.filteredDocuments.length,
                                itemBuilder: (context, index) {
                                  final document =
                                      _controller.filteredDocuments[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    DocumentDetailScreen(
                                                      title: document.title,
                                                      content: document.content,
                                                      category:
                                                          document.category,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              document.content,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                document.category,
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontSize: 12,
                                                ),
                                              ),
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
            },
          );
        },
      ),
    );
  }
}
