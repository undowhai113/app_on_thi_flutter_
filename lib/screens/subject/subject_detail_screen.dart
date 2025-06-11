import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../quiz/practice_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subjectName;
  final String groupName;

  const SubjectDetailScreen({
    super.key,
    required this.subjectName,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.backgroundColor],
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(context, 'Tài liệu', Icons.book, Colors.blue, () {
              Navigator.pushNamed(
                context,
                '/theory',
                arguments: {'subjectName': subjectName, 'groupName': groupName},
              );
            }),
            _buildFeatureCard(
              context,
              'Công thức',
              Icons.science,
              Colors.green,
              () {
                Navigator.pushNamed(
                  context,
                  '/formulas',
                  arguments: {
                    'subjectName': subjectName,
                    'groupName': groupName,
                  },
                );
              },
            ),
            _buildFeatureCard(
              context,
              'Làm kiểm tra',
              Icons.quiz,
              Colors.orange,
              () {
                Navigator.pushNamed(
                  context,
                  '/quiz',
                  arguments: {'subjectName': subjectName},
                );
              },
            ),
            _buildFeatureCard(
              context,
              'Ôn tập',
              Icons.school,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PracticeScreen(
                          subjectName: subjectName,
                          groupName: groupName,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
