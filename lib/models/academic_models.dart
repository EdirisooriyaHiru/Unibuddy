/// A single downloadable/openable resource.
class SubjectResource {
  final String title;
  final String? url;

  const SubjectResource(
    this.title, {
    this.url,
  });
}

/// One subject inside a semester.
class Subject {
  final String code;
  final String name;
  final String credits;
  final List<SubjectResource> pastPapers;
  final List<SubjectResource> lectureSlides;
  final List<String> quizIds;

  const Subject({
    required this.code,
    required this.name,
    required this.credits,
    this.pastPapers = const [],
    this.lectureSlides = const [],
    this.quizIds = const [],
  });
}

/// One semester inside a year.
class SemesterData {
  final String title;
  final List<Subject> subjects;

  const SemesterData({
    required this.title,
    required this.subjects,
  });
}

/// One academic year.
class YearData {
  final String title;
  final List<SemesterData> semesters;

  const YearData({
    required this.title,
    required this.semesters,
  });
}