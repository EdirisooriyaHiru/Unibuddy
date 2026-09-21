import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/quiz_data.dart';
import '../../models/academic_models.dart';
import '../../models/quiz_models.dart';
import '../../theme/app_theme.dart';
import '../quiz/quiz_question_screen.dart';

/// Final screen in the Academic flow:
/// Year -> Semester -> Subject -> Quiz / Past Papers / Lecture Slides.
///
/// Lecture Slides are loaded from Firebase:
///
/// subjects
///   └── SUBJECT_CODE
///       └── notes
///           ├── chapter01
///           │   ├── title
///           │   └── url
///           └── chapter02
///               ├── title
///               └── url
class SubjectResourcesScreen extends StatelessWidget {
  final Subject subject;

  const SubjectResourcesScreen({
    super.key,
    required this.subject,
  });

  // ===========================================================================
  // OPEN A RESOURCE
  // ===========================================================================

  Future<void> _openResource(
    BuildContext context,
    SubjectResource resource,
  ) async {
    final url = resource.url;

    if (url == null || url.trim().isEmpty) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item will be added soon.'),
        ),
      );

      return;
    }

    await _openUrl(
      context,
      url,
    );
  }

  // ===========================================================================
  // OPEN FIREBASE NOTE
  // ===========================================================================

  Future<void> _openFirebaseNote(
    BuildContext context,
    String title,
    String url,
  ) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document link is not available.'),
        ),
      );

      return;
    }

    await _openUrl(
      context,
      url,
    );
  }

  // ===========================================================================
  // DIRECT OPEN
  //
  // PDF  -> browser / PDF viewer
  // DOCX -> browser / Word / document viewer
  //
  // No extra PDF package is required.
  // ===========================================================================

  Future<void> _openUrl(
    BuildContext context,
    String url,
  ) async {
    final uri = Uri.tryParse(
      url.trim(),
    );

    if (uri == null ||
        !uri.hasScheme ||
        (!uri.isScheme('http') &&
            !uri.isScheme('https'))) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid document link.'),
        ),
      );

      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open this document.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open document: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // NORMAL RESOURCE LIST
  //
  // Used for Past Papers.
  // ===========================================================================

  Widget _resourceList(
    BuildContext context,
    List<SubjectResource> items,
    IconData icon,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nothing added here yet.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  purple.withOpacity(.12),
              child: Icon(
                icon,
                color: purple,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              item.url == null
                  ? 'Coming soon'
                  : 'Tap to open',
            ),
            trailing: Icon(
              item.url == null
                  ? Icons.hourglass_empty
                  : Icons.open_in_new,
            ),
            onTap: () {
              _openResource(
                context,
                item,
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // QUIZ LIST
  // ===========================================================================

  Widget _quizList(
    BuildContext context,
  ) {
    final subjectQuizzes = quizzes
        .where(
          (quiz) =>
              subject.quizIds.contains(
            quiz.id,
          ),
        )
        .toList();

    if (subjectQuizzes.isEmpty) {
      return const Center(
        child: Text(
          'No quizzes added for this subject yet.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjectQuizzes.length,
      itemBuilder: (context, i) {
        final QuizItem quiz =
            subjectQuizzes[i];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  purple.withOpacity(.12),
              child: const Icon(
                Icons.quiz,
                color: purple,
              ),
            ),
            title: Text(
              quiz.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              quiz.subtitle,
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QuizQuestionScreen(
                    quiz: quiz,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // FIREBASE LECTURE SLIDES
  //
  // Firebase path:
  //
  // subjects/{subject.code}/notes
  //
  // Example:
  //
  // subjects
  //   ITIC1113
  //      notes
  //         chapter01
  //            title: Information Technology Concepts - Chapter 01
  //            url: https://...
  // ===========================================================================

  Widget _firebaseLectureSlides(
    BuildContext context,
  ) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subject.code)
          .collection('notes')
          .snapshots(),
      builder: (context, snapshot) {
        // ---------------------------------------------------------------------
        // LOADING
        // ---------------------------------------------------------------------

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ---------------------------------------------------------------------
        // FIREBASE ERROR
        // ---------------------------------------------------------------------

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Could not load lecture slides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ---------------------------------------------------------------------
        // GET DOCUMENTS
        // ---------------------------------------------------------------------

        final docs =
            snapshot.data?.docs ?? [];

        // ---------------------------------------------------------------------
        // EMPTY
        // ---------------------------------------------------------------------

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 52,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No lecture slides added yet.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // ---------------------------------------------------------------------
        // LIST
        // ---------------------------------------------------------------------

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data =
                docs[index].data();

            final title =
                data['title']?.toString() ??
                    'Lecture Material';

            final url =
                data['url']?.toString() ?? '';

            final fileType =
                _getFileType(url);

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                // -------------------------------------------------------------
                // ICON
                // -------------------------------------------------------------

                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      purple.withOpacity(.12),
                  child: Icon(
                    fileType == 'PDF'
                        ? Icons.picture_as_pdf
                        : fileType == 'DOCX'
                            ? Icons.description
                            : Icons.insert_drive_file,
                    color: purple,
                    size: 25,
                  ),
                ),

                // -------------------------------------------------------------
                // TITLE
                // -------------------------------------------------------------

                title: Text(
                  title,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // -------------------------------------------------------------
                // SUBTITLE
                // -------------------------------------------------------------

                subtitle: Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 4,
                  ),
                  child: Text(
                    fileType == 'PDF'
                        ? 'PDF • Tap to open'
                        : fileType == 'DOCX'
                            ? 'DOCX • Tap to open'
                            : 'Document • Tap to open',
                  ),
                ),

                // -------------------------------------------------------------
                // OPEN ICON
                // -------------------------------------------------------------

                trailing: const Icon(
                  Icons.open_in_new,
                ),

                // -------------------------------------------------------------
                // OPEN
                // -------------------------------------------------------------

                onTap: () {
                  _openFirebaseNote(
                    context,
                    title,
                    url,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // FILE TYPE
  // ===========================================================================

  String _getFileType(String url) {
    final cleanUrl =
        url.toLowerCase().split('?').first;

    if (cleanUrl.endsWith('.pdf')) {
      return 'PDF';
    }

    if (cleanUrl.endsWith('.docx') ||
        cleanUrl.endsWith('.doc')) {
      return 'DOCX';
    }

    return 'FILE';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            subject.name,
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Quiz',
              ),
              Tab(
                text: 'Past Papers',
              ),
              Tab(
                text: 'Lecture Slides',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ---------------------------------------------------------------
            // 1. QUIZ
            // ---------------------------------------------------------------

            _quizList(context),

            // ---------------------------------------------------------------
            // 2. PAST PAPERS
            // ---------------------------------------------------------------

            _resourceList(
              context,
              subject.pastPapers,
              Icons.description_outlined,
            ),

            // ---------------------------------------------------------------
            // 3. LECTURE SLIDES
            // Firebase Firestore
            // ---------------------------------------------------------------

            _firebaseLectureSlides(
              context,
            ),
          ],
        ),
      ),
    );
  }
}