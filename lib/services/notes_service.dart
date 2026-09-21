import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A single note document.
class NoteItem {
  final String id;
  final String title;
  final String content;

  NoteItem({required this.id, required this.title, required this.content});

  factory NoteItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return NoteItem(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }
}

/// Stores notes under `users/{uid}/notes` so every student only sees
/// and edits their own notes.
class NotesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('notes');
  }

  /// Live stream of the current user's notes, newest first.
  Stream<List<NoteItem>> watchNotes() {
    final col = _collection;
    if (col == null) return const Stream.empty();
    return col.orderBy('updatedAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(NoteItem.fromDoc).toList(),
        );
  }

  Future<void> addNote(String title, String content) async {
    final col = _collection;
    if (col == null) return;
    await col.add({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(id).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(id).delete();
  }
}
