import '../models/quiz_models.dart';

/// ---------------------------------------------------------------------
/// EDIT THIS FILE to add or change quizzes.
/// Each QuizItem has a list of QuizQuestion. `correctIndex` is the
/// index (starting at 0) of the correct option in `options`.
/// ---------------------------------------------------------------------

final List<QuizItem> quizzes = [
  QuizItem(
    id: 'quiz1',
    title: 'Quiz 1 - Variables',
    subtitle: '5 Questions',
    questions: [
      QuizQuestion(
        question: 'Which keyword declares a variable in Dart?',
        options: const ['int', 'var', 'let', 'val'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Which of these is a valid variable name?',
        options: const ['1name', 'my-name', 'myName', 'my name'],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: 'What data type is used to store true/false values?',
        options: const ['bool', 'String', 'int', 'double'],
        correctIndex: 0,
      ),
      QuizQuestion(
        question: 'Which keyword makes a variable constant at compile time?',
        options: const ['final', 'const', 'static', 'var'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'What is the default value of an uninitialized int variable?',
        options: const ['0', 'null', '-1', 'undefined'],
        correctIndex: 1,
      ),
    ],
  ),
  QuizItem(
    id: 'quiz2',
    title: 'Quiz 2 - Loops',
    subtitle: '4 Questions',
    questions: [
      QuizQuestion(
        question: 'Which loop runs its body at least once?',
        options: const ['for', 'while', 'do-while', 'foreach'],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: 'Which keyword stops a loop immediately?',
        options: const ['stop', 'break', 'continue', 'exit'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Which keyword skips to the next loop iteration?',
        options: const ['continue', 'break', 'skip', 'next'],
        correctIndex: 0,
      ),
      QuizQuestion(
        question: 'What does "for (var i = 0; i < 5; i++)" repeat?',
        options: const ['4 times', '5 times', '6 times', 'forever'],
        correctIndex: 1,
      ),
    ],
  ),
  QuizItem(
    id: 'quiz3',
    title: 'Quiz 3 - Arrays / Lists',
    subtitle: '4 Questions',
    questions: [
      QuizQuestion(
        question: 'Which type represents a list in Dart?',
        options: const ['List<T>', 'Array<T>', 'Set<T>', 'Map<T>'],
        correctIndex: 0,
      ),
      QuizQuestion(
        question: 'What is the index of the first element in a list?',
        options: const ['1', '0', '-1', 'depends'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Which method adds an item to the end of a list?',
        options: const ['add()', 'push()', 'append()', 'insert()'],
        correctIndex: 0,
      ),
      QuizQuestion(
        question: 'Which property returns how many items are in a list?',
        options: const ['count', 'size', 'length', 'total'],
        correctIndex: 2,
      ),
    ],
  ),
  QuizItem(
    id: 'quiz4',
    title: 'Quiz 4 - Functions',
    subtitle: '3 Questions',
    questions: [
      QuizQuestion(
        question: 'Which keyword is used to return a value from a function?',
        options: const ['return', 'give', 'send', 'output'],
        correctIndex: 0,
      ),
      QuizQuestion(
        question: 'What do we call a function with no name, used inline?',
        options: const ['Named function', 'Anonymous function', 'Static function', 'Void function'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'What type does a function return if it returns nothing?',
        options: const ['null', 'void', 'empty', 'none'],
        correctIndex: 1,
      ),
    ],
  ),
];
