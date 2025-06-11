import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  static final List<Map<String, dynamic>> subjects = [
    {
      'displayName': 'Toán học',
      'id': 'Toán',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'groupName': 'KHTN',
    },
    {
      'displayName': 'Vật lý',
      'id': 'Lý',
      'icon': Icons.science,
      'color': Colors.purple,
      'groupName': 'KHTN',
    },
    {
      'displayName': 'Hóa học',
      'id': 'Hóa',
      'icon': Icons.science_outlined,
      'color': Colors.green,
      'groupName': 'KHTN',
    },
    {
      'displayName': 'Sinh học',
      'id': 'Sinh',
      'icon': Icons.biotech,
      'color': Colors.teal,
      'groupName': 'KHTN',
    },
    {
      'displayName': 'Tiếng Anh',
      'id': 'Anh',
      'icon': Icons.language,
      'color': Colors.orange,
      'groupName': 'KHXH',
    },
    {
      'displayName': 'Ngữ văn',
      'id': 'Văn',
      'icon': Icons.menu_book,
      'color': Colors.red,
      'groupName': 'KHXH',
    },
    {
      'displayName': 'Lịch sử',
      'id': 'Sử',
      'icon': Icons.history_edu,
      'color': Colors.brown,
      'groupName': 'KHXH',
    },
    {
      'displayName': 'Địa lý',
      'id': 'Địa',
      'icon': Icons.public,
      'color': Colors.indigo,
      'groupName': 'KHXH',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Môn học'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), _buildSubjectGrid(context)],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 4, 46, 80),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn môn học',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Học tập hiệu quả - Chìa khóa vàng cho mọi thành công!.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid(BuildContext context) {
    // Lọc ra các môn KHTN và KHXH
    final khtnSubjects =
        subjects.where((s) => s['groupName'] == 'KHTN').toList();
    final khxhSubjects =
        subjects.where((s) => s['groupName'] == 'KHXH').toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khoa học tự nhiên',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: khtnSubjects.length,
            itemBuilder: (context, index) {
              final subject = khtnSubjects[index];
              return _buildSubjectCard(context, subject);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Khoa học xã hội',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: khxhSubjects.length,
            itemBuilder: (context, index) {
              final subject = khxhSubjects[index];
              return _buildSubjectCard(context, subject);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/subject-detail',
            arguments: {
              'subjectName': subject['id'],
              'groupName': subject['groupName'],
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                subject['color'] as Color,
                (subject['color'] as Color).withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  subject['icon'] as IconData,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  subject['displayName'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Giới hạn số dòng
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
