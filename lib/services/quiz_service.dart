import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Saves quiz attempts under `users/{uid}/quiz_results` and can read
/// back the best/last score for a quiz so QuizListScreen can show
/// "Not attempted" vs a real percentage.
class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('quiz_results');
  }

  Future<void> saveResult({
    required String quizId,
    required String quizTitle,
    required int correct,
    required int total,
  }) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(quizId).set({
      'quizTitle': quizTitle,
      'correct': correct,
      'total': total,
      'percentage': total == 0 ? 0 : ((correct / total) * 100).round(),
      'attemptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live stream of results keyed by quizId -> percentage score.
  Stream<Map<String, int>> watchResults() {
    final col = _collection;
    if (col == null) return const Stream.empty();
    return col.snapshots().map((snap) {
      final map = <String, int>{};
      for (final doc in snap.docs) {
        map[doc.id] = (doc.data()['percentage'] ?? 0) as int;
      }
      return map;
    });
  }
}
