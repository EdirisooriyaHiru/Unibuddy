import 'package:flutter/material.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizItem quiz;
  final int correct;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.correct,
    required this.total,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    // Save this attempt to Firestore as soon as the result screen opens.
    QuizService().saveResult(
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      correct: widget.correct,
      total: widget.total,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wrong = widget.total - widget.correct;
    final percentage = widget.total == 0 ? 0 : ((widget.correct / widget.total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 110, color: Colors.amber),
              const SizedBox(height: 15),
              const Text('Great Job!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              ListTile(title: const Text('Score'), trailing: Text('${widget.correct} / ${widget.total}')),
              ListTile(title: const Text('Percentage'), trailing: Text('$percentage%')),
              ListTile(title: const Text('Correct Answers'), trailing: Text('${widget.correct}')),
              ListTile(title: const Text('Wrong Answers'), trailing: Text('$wrong')),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Quizzes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
