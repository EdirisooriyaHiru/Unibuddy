import '../models/academic_models.dart';

/// Complete BSc IT module structure used by Academic and Attendance.
/// Attendance derives weekly class sessions from the module credit value.
const List<YearData> academicYears = [
  YearData(
    title: 'Year 1',
    semesters: [
      SemesterData(title: 'Semester 1', subjects: [
        Subject(code: 'ITIC1113', name: 'Information Technology Concepts', credits: '3 Credits', quizIds: ['quiz1']),
        Subject(code: 'ITIC1123', name: 'Fundamentals of Programming', credits: '3 Credits'),
        Subject(code: 'ITIC1132', name: 'Fundamentals of Visual Computing', credits: '2 Credits'),
        Subject(code: 'ITIC1112', name: 'Fundamentals of Mathematics', credits: '2 Credits'),
        Subject(code: 'ITIC1143', name: 'Fundamentals of Electrical Engineering', credits: '3 Credits'),
        Subject(code: 'ITIC1152', name: 'Programming Laboratory', credits: '2 Credits'),
        Subject(code: 'ITIC1172', name: 'Operating Systems', credits: '2 Credits'),
        Subject(code: 'DL1112', name: 'English I', credits: '2 Credits (NGPA)'),
      ]),
      SemesterData(title: 'Semester 2', subjects: [
        Subject(code: 'ITIC1213', name: 'Computer Architecture and Organization', credits: '3 Credits'),
        Subject(code: 'ITIC1223', name: 'Basics of Digital and Analog Electronics', credits: '3 Credits'),
        Subject(code: 'ITIC1233', name: 'Database Systems', credits: '3 Credits'),
        Subject(code: 'ITIC1243', name: 'Web Design and Development', credits: '3 Credits'),
        Subject(code: 'ITIC1212', name: 'Probability and Statistics', credits: '2 Credits'),
        Subject(code: 'ITIC1282', name: 'Skill Development Project I', credits: '2 Credits'),
        Subject(code: 'ITIC1272', name: 'Principles of Management', credits: '2 Credits (NGPA)'),
        Subject(code: 'LC1211', name: 'Communication Skills I', credits: '1 Credit (NGPA)'),
        Subject(code: 'DL1211', name: 'English II', credits: '1 Credit (NGPA)'),
      ]),
    ],
  ),
  YearData(
    title: 'Year 2',
    semesters: [
      SemesterData(title: 'Semester 1', subjects: [
        Subject(code: 'ITIC2113', name: 'Software Engineering', credits: '3 Credits'),
        Subject(code: 'ITIC2123', name: 'Object Oriented Programming', credits: '3 Credits'),
        Subject(code: 'ITIC2133', name: 'Data Communication and Networking', credits: '3 Credits'),
        Subject(code: 'ITIC2143', name: 'Data Structures and Algorithms', credits: '3 Credits'),
        Subject(code: 'ITIC2153', name: 'Professional Ethics', credits: '3 Credits'),
        Subject(code: 'ITIC2112', name: 'Calculus I', credits: '2 Credits'),
        Subject(code: 'ITIC2162', name: 'Career Development Plan', credits: '2 Credits'),
        Subject(code: 'LC2111', name: 'Communication Skills II', credits: '1 Credit (NGPA)'),
        Subject(code: 'DL2111', name: 'English III', credits: '1 Credit (NGPA)'),
      ]),
      SemesterData(title: 'Semester 2', subjects: [
        Subject(code: 'ITIC2212', name: 'System Administration and Maintenance', credits: '2 Credits'),
        Subject(code: 'ITIC2223', name: 'Advanced Programming', credits: '3 Credits'),
        Subject(code: 'ITIC2232', name: 'Cyber Security', credits: '2 Credits'),
        Subject(code: 'ITIC2243', name: 'Systems Analysis and Design', credits: '3 Credits'),
        Subject(code: 'ITIC2252', name: 'Graphic Designing and Animation', credits: '2 Credits'),
        Subject(code: 'ITIC2262', name: 'Open-Source Development', credits: '2 Credits'),
        Subject(code: 'ITIC2272', name: 'Skill Development Project II', credits: '2 Credits'),
        Subject(code: 'ITIC2282', name: 'Information Technology Law', credits: '1 Credit (NGPA)'),
        Subject(code: 'TETE2211', name: 'Tamil Basics for Beginners', credits: '1 Credit (NGPA)'),
        Subject(code: 'TETE2221', name: 'Sinhala Basics for Beginners', credits: '1 Credit (NGPA)'),
        Subject(code: 'LC2211', name: 'Communication Skills III', credits: '1 Credit (NGPA)'),
        Subject(code: 'DL2211', name: 'English IV', credits: '1 Credit (NGPA)'),
      ]),
    ],
  ),
  YearData(
    title: 'Year 3',
    semesters: [
      SemesterData(title: 'Semester 1', subjects: [
        Subject(code: 'ITIC3112', name: 'Mobile Application Development', credits: '2 Credits'),
        Subject(code: 'ITIC3123', name: 'Information Security', credits: '3 Credits'),
        Subject(code: 'ITIC3132', name: 'IT Project Management', credits: '2 Credits'),
        Subject(code: 'ITIC3142', name: 'IOT Applications', credits: '2 Credits'),
        Subject(code: 'ITIC3152', name: 'Human Computer Interaction', credits: '2 Credits'),
        Subject(code: 'ITIC3163', name: 'Management Information Systems', credits: '3 Credits'),
        Subject(code: 'TETE3112', name: 'Dancing', credits: '2 Credits (NGPA)'),
        Subject(code: 'TETE3122', name: 'Photography', credits: '2 Credits (NGPA)'),
        Subject(code: 'LC3111', name: 'Communication Skills IV', credits: '1 Credit (NGPA)'),
        Subject(code: 'DL3111', name: 'English V', credits: '1 Credit (NGPA)'),
      ]),
      SemesterData(title: 'Semester 2', subjects: [
        Subject(code: 'ITIC3216', name: 'Industrial Training', credits: '6 Credits'),
      ]),
    ],
  ),
  YearData(
    title: 'Year 4',
    semesters: [
      SemesterData(title: 'Semester 1', subjects: [
        Subject(code: 'ITIC4113', name: 'Embedded Systems', credits: '3 Credits'),
        Subject(code: 'ITIC4122', name: 'Advanced Software Systems Design', credits: '2 Credits'),
        Subject(code: 'ITIC4132', name: 'Research Methodology', credits: '2 Credits'),
        Subject(code: 'ITIC4143', name: 'Emerging Technologies in ICT', credits: '3 Credits'),
        Subject(code: 'ITIC4152', name: 'Data Science', credits: '2 Credits'),
        Subject(code: 'ITIE4113', name: 'Advanced Computer Networks', credits: '3 Credits (Elective)'),
        Subject(code: 'ITIE4123', name: 'Game Development', credits: '3 Credits (Elective)'),
        Subject(code: 'ITIE4133', name: 'E-Commerce', credits: '3 Credits (Elective)'),
        Subject(code: 'ITIE4143', name: 'UI and UX Engineering', credits: '3 Credits (Elective)'),
      ]),
      SemesterData(title: 'Semester 2', subjects: [
        Subject(code: 'ITIC4212', name: 'Artificial Intelligence', credits: '2 Credits'),
        Subject(code: 'ITIC4223', name: 'Cloud Computing', credits: '3 Credits'),
        Subject(code: 'ITIC4232', name: 'Software Quality Assurance', credits: '2 Credits'),
        Subject(code: 'ITIC4246', name: 'Skill Development Project – Individual', credits: '6 Credits'),
        Subject(code: 'ITIC4252', name: 'Entrepreneurship', credits: '2 Credits'),
      ]),
    ],
  ),
];
