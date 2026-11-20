import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'cars_comparison.dart';
import 'cars_models.dart';
import 'cars_report_screen.dart';
import 'cars_store.dart';

/// The CARS questionnaire: one area at a time, then a summary the parent
/// can show to a clinician. It is not a diagnosis.
class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _noteController = TextEditingController();
  final List<int?> _scores =
      List<int?>.filled(CarsQuestionnaire.itemCount, null);

  int _index = 0;
  CarsResult? _result;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isLast => _index == CarsQuestionnaire.itemCount - 1;
  int get _answered => _scores.whereType<int>().length;

  Future<void> _next() async {
    if (_scores[_index] == null) return;

    if (!_isLast) {
      setState(() => _index++);
      return;
    }

    final result = CarsResult(
      takenAt: DateTime.now(),
      scores: _scores.whereType<int>().toList(),
      note: _noteController.text.trim(),
    );

    await carsStore.add(widget.child.id, result);
    if (!mounted) return;

    setState(() => _result = result);
    _openReport(result);
  }

  /// Opens the PDF report. It compares with the assessment before this one.
  void _openReport(CarsResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarsReportScreen(child: widget.child, result: result),
      ),
    );
  }

  void _retake() {
    setState(() {
      _scores.fillRange(0, _scores.length, null);
      _noteController.clear();
      _index = 0;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'CARS • ${widget.child.name}'),
      body: SafeArea(
        child: result == null ? _question() : _summary(result),
      ),
    );
  }

  // ------------------------------------------------------------ question

  Widget _question() {
    final item = CarsQuestionnaire.items[_index];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _answered / CarsQuestionnaire.itemCount,
                        minHeight: 8,
                        color: ParentUi.purple,
                        backgroundColor: ParentUi.soft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_index + 1} / ${CarsQuestionnaire.itemCount}',
                    style: const TextStyle(
                      color: ParentUi.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: ParentUi.purple,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.helper,
                      style: const TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final level in CarsQuestionnaire.levels)
                _LevelTile(
                  level: level,
                  selected: _scores[_index] == level.score,
                  onTap: () => setState(() => _scores[_index] = level.score),
                ),
              if (_isLast) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Add a note for the doctor (optional)',
                    hintText: 'e.g. avoids eye contact when overwhelmed…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              if (_index > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _index--),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(90, 52),
                    foregroundColor: ParentUi.purple,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Back'),
                ),
              if (_index > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _scores[_index] == null ? null : _next,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: ParentUi.purple,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(_isLast ? 'See summary' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- summary

  Widget _summary(CarsResult result) {
    final band = result.band;
    final history = carsStore.of(widget.child.id);
    final index = history.indexOf(result);
    final comparison = CarsComparison.compare(
      result,
      (index != -1 && index + 1 < history.length) ? history[index + 1] : null,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        CarsSummaryCard(result: result),
        const SizedBox(height: 16),
        ParentCard(
          child: Text(
            comparison.headline,
            style: const TextStyle(
              color: ParentUi.dark,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ParentCard(
          child: Text(
            band.description,
            style: const TextStyle(color: ParentUi.dark, height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        const ParentCard(
          child: Text(
            'This is not a diagnosis. Share this report with your clinician. '
            'Only a trained professional can interpret it.',
            style: TextStyle(color: ParentUi.muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => _openReport(result),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: ParentUi.purple,
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Open PDF report'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: ParentUi.purple,
            shape: const StadiumBorder(),
          ),
          child: const Text('Done'),
        ),
        TextButton(onPressed: _retake, child: const Text('Retake assessment')),
      ],
    );
  }
}

/// Total score, band and the score of every area. Used after the
/// questionnaire and in the history.
class CarsSummaryCard extends StatelessWidget {
  const CarsSummaryCard({super.key, required this.result});

  final CarsResult result;

  @override
  Widget build(BuildContext context) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${result.total} / ${CarsQuestionnaire.maxScore}',
            style: const TextStyle(
              color: ParentUi.purple,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            result.band.label,
            style: const TextStyle(
              color: ParentUi.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < CarsQuestionnaire.itemCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      CarsQuestionnaire.items[i].title,
                      style: const TextStyle(
                        color: ParentUi.dark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${result.scores[i]}',
                    style: const TextStyle(
                      color: ParentUi.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (result.note.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Note: ${result.note}',
              style: const TextStyle(color: ParentUi.muted, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final CarsLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? ParentUi.soft : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? ParentUi.purple : ParentUi.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    selected ? ParentUi.purple : ParentUi.soft,
                child: Text(
                  '${level.score}',
                  style: TextStyle(
                    color: selected ? Colors.white : ParentUi.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: const TextStyle(
                        color: ParentUi.dark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      level.description,
                      style: const TextStyle(
                        color: ParentUi.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
