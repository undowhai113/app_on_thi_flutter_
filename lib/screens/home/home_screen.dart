import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../history/quiz_history_screen.dart';
//import '../progress/progress_screen.dart';
//import '../../widgets/exam_countdown_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ôn Thi THPT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Chào mừng bạn đến với ứng dụng',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                accountName: Text(
                  user?.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.displayName ?? 'A')[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'Lịch sử làm bài',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.timer,
                title: 'Hẹn giờ nhắc nhở',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/reminders');
                },
              ),
              _buildDrawerItem(
                icon: Icons.calendar_today,
                title: 'Đếm ngược kỳ thi',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/countdown');
                },
              ),
              _buildDrawerItem(
                icon: Icons.trending_up,
                title: 'Tiến độ học tập',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/progress');
                },
              ),
              const Divider(color: Colors.white24),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
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
            _buildSubjectGroupCard(context, 'Khối A', [
              'Toán',
              'Lý',
              'Hóa',
            ], const Color(0xFF2196F3)),
            _buildSubjectGroupCard(context, 'Khối A1', [
              'Toán',
              'Lý',
              'Anh',
            ], const Color(0xFF4CAF50)),
            _buildSubjectGroupCard(context, 'Khối B', [
              'Toán',
              'Hóa',
              'Sinh',
            ], const Color(0xFFE91E63)),
            _buildSubjectGroupCard(context, 'Khối C', [
              'Văn',
              'Sử',
              'Địa',
            ], const Color(0xFFFF9800)),
            _buildSubjectGroupCard(context, 'Khối D', [
              'Toán',
              'Văn',
              'Anh',
            ], const Color(0xFF9C27B0)),
            _buildSubjectGroupCard(context, 'Khối A2', [
              'Toán',
              'Lý',
              'Sinh',
            ], const Color(0xFF795548)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Môn học'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/subjects');
          }
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildSubjectGroupCard(
    BuildContext context,
    String title,
    List<String> subjects,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder:
                (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...subjects.map(
                        (subject) => ListTile(
                          title: Text(
                            subject,
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/subject-detail',
                              arguments: {
                                'subjectName': subject,
                                'groupName': title,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...subjects.map(
                (subject) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    subject,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
