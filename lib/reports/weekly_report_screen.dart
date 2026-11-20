import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../care/care_stores.dart';
import '../child.dart';
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'weekly_pdf.dart';
import 'weekly_stats.dart';

/// The weekly PDF report of a child. The parent can look at the last 7
/// days or at earlier weeks; each week is compared with the week before.
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  static const _choices = ['Last 7 days', 'Week before', '2 weeks ago'];

  int _weeksAgo = 0;
  late final Future<void> _ready = _load();

  Future<void> _load() async {
    await ChildAppState.instance.switchChild(widget.child.id);
    await loadChildRecords(widget.child.id);
  }

  WeekStats _stats(ReportWeek week) {
    final id = widget.child.id;
    final data = ChildAppState.instance;

    return WeekStats.collect(
      week: week,
      completions: data.completionHistory,
      focus: data.focusSessions,
      moods: data.moodHistory,
      dailyLogs: dailyLogStore.of(id),
      triggers: triggerStore.of(id),
      notes: schoolNoteStore.of(id),
    );
  }

  Future<Uint8List> _build() async {
    final font = await rootBundle.load('fonts/Cairo-Regular.ttf');
    final thisWeek = ReportWeek.endingOn(DateTime.now(), weeksAgo: _weeksAgo);

    return WeeklyPdf.build(
      childName: widget.child.name,
      childAge: widget.child.age,
      comparison: WeeklyComparison.compare(
        _stats(thisWeek),
        _stats(thisWeek.previous),
      ),
      fontData: font,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Weekly report'),
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < _choices.length; i++)
                      ChoiceChip(
                        label: Text(_choices[i]),
                        selected: _weeksAgo == i,
                        onSelected: (_) => setState(() => _weeksAgo = i),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PdfPreview(
                  key: ValueKey(_weeksAgo),
                  build: (_) => _build(),
                  pdfFileName:
                      'MAZID-weekly-${widget.child.name}-$_weeksAgo.pdf',
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  previewPageMargin: const EdgeInsets.all(8),
                  onError: (context, error) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'The report could not be created. Please try again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
