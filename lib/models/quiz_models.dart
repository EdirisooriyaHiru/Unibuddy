/// One multiple-choice question inside a quiz.
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// One quiz, made of several questions.
class QuizItem {
  final String id;
  final String title;
  final String subtitle;
  final List<QuizQuestion> questions;

  const QuizItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questions,
  });
}
