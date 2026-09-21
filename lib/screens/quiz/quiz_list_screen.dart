import 'package:flutter/material.dart';
import '../../data/quiz_data.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';
import 'quiz_question_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();

    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: StreamBuilder<Map<String, int>>(
        stream: quizService.watchResults(),
        builder: (context, snapshot) {
          final results = snapshot.data ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: quizzes.map((QuizItem quiz) {
              final score = results[quiz.id];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE7F6),
                    child: Icon(Icons.quiz, color: purple),
                  ),
                  title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(quiz.subtitle),
                  trailing: score == null
                      ? FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuizQuestionScreen(quiz: quiz)),
                          ),
                          child: const Text('Start'),
                        )
                      : TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuizQuestionScreen(quiz: quiz)),
                          ),
                          child: Text('$score%',
                              style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
