import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/study_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/theory/theory_screen.dart';
import 'screens/quiz/quiz_result_screen.dart';
import 'theme/app_theme.dart';
import 'screens/subject/subject_detail_screen.dart';
import 'screens/subject/subject_screen.dart';
import 'screens/quiz/exam_list_screen.dart';
import 'screens/formula/formula_list_screen.dart';
import 'screens/reminder/reminder_screen.dart';
import 'screens/countdown/countdown_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/history/quiz_history_screen.dart';
import 'widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
      ],
      child: MaterialApp(
        title: 'Ôn Thi THPT',
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/subject-detail': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return SubjectDetailScreen(
              subjectName: args['subjectName'],
              groupName: args['groupName'],
            );
          },
          '/theory': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return TheoryScreen(
              subjectName: args['subjectName'],
              groupName: args['groupName'],
            );
          },
          '/quiz': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return ExamListScreen(subjectName: args['subjectName']);
          },
          '/quiz-result': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return QuizResultScreen(
              subjectName: args['subjectName'],
              score: args['score'],
              totalQuestions: args['totalQuestions'],
              questions: args['questions'],
              userAnswers: args['userAnswers'],
            );
          },
          '/formulas': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return FormulaListScreen(
              subjectName: args['subjectName'],
              groupName: args['groupName'],
            );
          },
          '/subjects': (context) => const SubjectScreen(),
          '/reminders': (context) => const ReminderScreen(),
          '/countdown': (context) => const CountdownScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/quiz-history': (context) => const QuizHistoryScreen(),
        },
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              if (child is LoadingScreen)
                const Positioned.fill(child: LoadingScreen()),
            ],
          );
        },
      ),
    );
  }
}
