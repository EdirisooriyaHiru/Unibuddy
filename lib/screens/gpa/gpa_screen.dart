import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

/// A weighted GPA calculator using the common 4.00 grading scale.
/// GPA = sum(credit hours × grade points) / sum(credit hours).
class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<int> _years = [1, 2, 3, 4];
  Map<int, double> _savedGpas = {};
  bool _loadingSaved = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _loadSavedGpas();
  }

  Future<void> _loadSavedGpas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('gpa_saved_by_year');
    if (raw != null) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(raw));
        _savedGpas = decoded.map((key, value) => MapEntry(int.parse(key), (value as num).toDouble()));
      } catch (_) {}
    }
    if (mounted) setState(() => _loadingSaved = false);
  }

  Future<void> _saveGpa(int year, double gpa) async {
    final prefs = await SharedPreferences.getInstance();
    _savedGpas[year] = double.parse(gpa.toStringAsFixed(2));
    await prefs.setString('gpa_saved_by_year', jsonEncode(_savedGpas.map((k, v) => MapEntry(k.toString(), v))));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openYear(BuildContext context, int year) {
    SystemSound.play(SystemSoundType.click);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GpaYearCalculatorScreen(
          year: year,
          onSaved: (gpa) => _saveGpa(year, gpa),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JourneyHeader(controller: _controller),
            const SizedBox(height: 20),
            const Text(
              'Choose Academic Year',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a year to manage your GPA subjects and calculate your results.',
              style: TextStyle(color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _years.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, index) {
                final year = _years[index];
                final start = (index * .12).clamp(0.0, .72);
                final end = (start + .28).clamp(0.28, 1.0);
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                );
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Opacity(
                    opacity: animation.value.clamp(0.0, 1.0).toDouble(),
                    child: Transform.translate(
                      offset: Offset(0, 28 * (1 - animation.value)),
                      child: Transform.scale(
                        scale: .94 + (.06 * animation.value),
                        child: child,
                      ),
                    ),
                  ),
                  child: _YearCard(
                    year: year,
                    index: index,
                    savedGpa: _savedGpas[year],
                    onTap: () => _openYear(context, year),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.controller});
  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purple, purple.withOpacity(.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RoutePainter()),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Positioned(
              left: -42 + (MediaQuery.sizeOf(context).width + 42) * controller.value,
              bottom: 42,
              child: child!,
            ),
            child: const Icon(Icons.train_rounded, color: Colors.white, size: 34),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Positioned(
              right: -36 + (MediaQuery.sizeOf(context).width * (1 - controller.value)),
              top: 18,
              child: child!,
            ),
            child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white70, size: 30),
          ),
          const Positioned(
            left: 18,
            top: 16,
            child: Text(
              'Your GPA Journey',
              style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
            ),
          ),
          const Positioned(
            left: 18,
            bottom: 15,
            child: Text(
              'Year by year • Track your academic progress',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.28)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(-10, size.height * .76)
      ..cubicTo(size.width * .25, size.height * .54, size.width * .45, size.height * .92, size.width * .67, size.height * .68)
      ..cubicTo(size.width * .82, size.height * .52, size.width * .9, size.height * .72, size.width + 10, size.height * .58);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YearCard extends StatelessWidget {
  const _YearCard({required this.year, required this.index, required this.onTap, this.savedGpa});
  final int year;
  final int index;
  final VoidCallback onTap;
  final double? savedGpa;

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.looks_one_rounded, Icons.looks_two_rounded, Icons.looks_3_rounded, Icons.looks_4_rounded];
    final accents = [const Color(0xFF5B5FEF), const Color(0xFF00897B), const Color(0xFFF57C00), const Color(0xFFD81B60)];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accents[index].withOpacity(.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icons[index], color: accents[index], size: 26),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black.withOpacity(.35)),
                ],
              ),
              const Spacer(),
              Text('Year ${year.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                savedGpa == null ? 'Open GPA' : 'Saved GPA  ${savedGpa!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: savedGpa == null ? Colors.black54 : Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: savedGpa == null ? FontWeight.normal : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GpaYearCalculatorScreen extends StatefulWidget {
  const GpaYearCalculatorScreen({super.key, required this.year, required this.onSaved});

  final int year;
  final Future<void> Function(double gpa) onSaved;

  @override
  State<GpaYearCalculatorScreen> createState() => _GpaYearCalculatorScreenState();
}

class _GpaRow {
  _GpaRow({this.name = '', this.credits = 3, this.grade = 'A'})
      : creditsController = TextEditingController(text: credits.toString());

  String name;
  int credits;
  String grade;
  final TextEditingController creditsController;

  void dispose() => creditsController.dispose();
}

class _GpaYearCalculatorScreenState extends State<GpaYearCalculatorScreen> {
  final List<_GpaRow> _subjects = [
    _GpaRow(name: 'Programming', credits: 3, grade: 'A+'),
    _GpaRow(name: 'Database', credits: 3, grade: 'A'),
    _GpaRow(name: 'Networking', credits: 3, grade: 'B+'),
    _GpaRow(name: 'Mathematics', credits: 2, grade: 'A-'),
  ];

  // Common 4.00 scale. F carries 0 points and is included in the denominator.
  static const Map<String, double> _gradePoints = {
    'A+': 4.00,
    'A': 4.00,
    'A-': 3.70,
    'B+': 3.30,
    'B': 3.00,
    'B-': 2.70,
    'C+': 2.30,
    'C': 2.00,
    'C-': 1.70,
    'D+': 1.30,
    'D': 1.00,
    'F': 0.00,
  };

  double get _totalCredits => _subjects.fold<double>(
        0,
        (sum, subject) => sum + subject.credits,
      );

  double get _totalQualityPoints => _subjects.fold<double>(
        0,
        (sum, subject) =>
            sum + subject.credits * (_gradePoints[subject.grade] ?? 0),
      );

  double get _gpa => _totalCredits == 0 ? 0 : _totalQualityPoints / _totalCredits;

  void _addSubject() {
    setState(() => _subjects.add(_GpaRow()));
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects[index].dispose();
      _subjects.removeAt(index);
    });
  }

  Future<void> _reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    setState(() {
      for (final subject in _subjects) {
        subject.dispose();
      }
      _subjects
        ..clear()
        ..addAll([
          _GpaRow(name: 'Programming', credits: 3, grade: 'A+'),
          _GpaRow(name: 'Database', credits: 3, grade: 'A'),
          _GpaRow(name: 'Networking', credits: 3, grade: 'B+'),
          _GpaRow(name: 'Mathematics', credits: 2, grade: 'A-'),
        ]);
    });
  }

  @override
  void dispose() {
    for (final subject in _subjects) {
      subject.dispose();
    }
    super.dispose();
  }

  bool _saving = false;

  String get _storageKey => 'gpa_year_${widget.year}_subjects';

  @override
  void initState() {
    super.initState();
    _loadSavedSubjects();
  }

  Future<void> _loadSavedSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List;
      final loaded = decoded
          .whereType<Map>()
          .map((item) => _GpaRow(
                name: item['name'] as String? ?? '',
                credits: (item['credits'] as num?)?.toInt() ?? 0,
                grade: item['grade'] as String? ?? 'A',
              ))
          .toList();
      if (!mounted || loaded.isEmpty) return;
      setState(() {
        for (final subject in _subjects) {
          subject.dispose();
        }
        _subjects
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {
      // Keep the default rows if saved data is malformed.
    }
  }

  Future<void> _saveAndExit() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_subjects.map((subject) => {
        'name': subject.name,
        'credits': subject.credits,
        'grade': subject.grade,
      }).toList()),
    );
    await widget.onSaved(_gpa);
    await SystemSound.play(SystemSoundType.click);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Year ${widget.year.toString().padLeft(2, '0')} GPA saved: ${_gpa.toStringAsFixed(2)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _saving) return;
        await _saveAndExit();
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text('Year ${widget.year.toString().padLeft(2, '0')} • GPA Calculator'),
        actions: [
          IconButton(
            tooltip: 'Save GPA',
            onPressed: _saving ? null : _saveAndExit,
            icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _summaryCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              itemCount: _subjects.length,
              itemBuilder: (context, index) => _subjectCard(index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    ));
  }

  Widget _summaryCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: purple,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Semester GPA',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _gpa.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 8,
              children: [
                _summaryItem('Credits', _formatNumber(_totalCredits)),
                _summaryItem('Quality Points', _totalQualityPoints.toStringAsFixed(2)),
                _summaryItem('Scale', '4.00'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _subjectCard(int index) {
    final subject = _subjects[index];
    final points = subject.credits * (_gradePoints[subject.grade] ?? 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: subject.name)
                      ..selection = TextSelection.collapsed(
                        offset: subject.name.length,
                      ),
                    decoration: const InputDecoration(
                      labelText: 'Subject name',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    onChanged: (value) => subject.name = value,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove subject',
                  onPressed: () => _removeSubject(index),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 360;

                final creditsField = TextField(
                  controller: subject.creditsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Credits',
                    prefixIcon: Icon(Icons.credit_score_outlined),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    setState(() => subject.credits = (parsed ?? 0).clamp(0, 30));
                  },
                );

                final gradeField = DropdownButtonFormField<String>(
                  value: subject.grade,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                  items: _gradePoints.keys
                      .map(
                        (grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(
                            '$grade  (${_gradePoints[grade]!.toStringAsFixed(2)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => subject.grade = value);
                  },
                );

                return narrow
                    ? Column(
                        children: [
                          creditsField,
                          const SizedBox(height: 10),
                          gradeField,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: creditsField),
                          const SizedBox(width: 10),
                          Expanded(child: gradeField),
                        ],
                      );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  'Quality points: ${points.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}
