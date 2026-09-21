import 'package:flutter/material.dart';
import '../../models/quiz_models.dart';
import 'quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final QuizItem quiz;
  const QuizQuestionScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;

  QuizQuestion get _question => widget.quiz.questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == widget.quiz.questions.length - 1;

  void _next() {
    if (_selectedOption == null) return;

    if (_selectedOption == _question.correctIndex) {
      _correctCount++;
    }

    if (_isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            quiz: widget.quiz,
            correct: _correctCount,
            total: widget.quiz.questions.length,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.quiz.questions.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_currentIndex + 1} of $total',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: (_currentIndex + 1) / total),
            const SizedBox(height: 28),
            Text(
              _question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            ..._question.options.asMap().entries.map((e) {
              return Card(
                child: RadioListTile<int>(
                  value: e.key,
                  groupValue: _selectedOption,
                  onChanged: (v) => setState(() => _selectedOption = v),
                  title: Text(e.value),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _selectedOption == null ? null : _next,
                child: Text(_isLastQuestion ? 'Finish' : 'Next'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
