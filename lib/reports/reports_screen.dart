import 'package:flutter/material.dart';

import '../care/medications_screen.dart' show formatDate;
import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'report_builder.dart';
import 'report_library.dart';
import 'saved_report_screen.dart';

/// Opens the reports folder of the child selected on the parent home.
void openSelectedChildReports(BuildContext context) {
  final child = ParentStore.instance.selectedChild;

  if (child == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add a child first to see reports.')),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ReportsScreen(child: child)),
  );
}

/// One folder per child that holds every report made for that child.
/// The weekly report is always there: opening the folder creates or
/// updates it. CARS and TOVA reports arrive when an assessment ends, and
/// the doctor report is made here as a PDF.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _ready = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    await ReportBuilder.prepare(widget.child);
    await ReportBuilder.saveWeekly(widget.child);
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _makeDoctorReport() async {
    setState(() => _busy = true);
    await ReportBuilder.prepare(widget.child);
    final report = await ReportBuilder.saveDoctor(widget.child);
    if (!mounted) return;
    setState(() => _busy = false);

    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The doctor report could not be saved. Try again.'),
        ),
      );
      return;
    }
    _open(report);
  }

  void _open(SavedReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedReportScreen(
          childId: widget.child.id,
          childName: widget.child.name,
          report: report,
        ),
      ),
    );
  }

  Future<void> _delete(SavedReport report) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this report?'),
        content: Text(report.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await ReportLibrary.instance.delete(widget.child.id, report);
  }

  static const _emptyText = {
    ReportKind.weekly: 'Created automatically every week.',
    ReportKind.cars: 'Saved here when you finish a CARS assessment.',
    ReportKind.tova: 'Saved here when your child finishes a TOVA activity.',
    ReportKind.doctor: 'Tap "Make doctor report" above.',
  };

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, "${child.name}'s reports"),
      body: SafeArea(
        child: !_ready
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: ReportLibrary.instance,
                builder: (context, _) {
                  final library = ReportLibrary.instance;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      Text(
                        '${library.of(child.id).length} reports saved in this folder',
                        style: const TextStyle(color: ParentUi.muted),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _busy ? null : _makeDoctorReport,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: ParentUi.purple,
                          shape: const StadiumBorder(),
                        ),
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.description_rounded),
                        label: Text(_busy ? 'Making...' : 'Make doctor report'),
                      ),
                      for (final kind in ReportKind.values) ...[
                        const SizedBox(height: 22),
                        Text(
                          kind.folderTitle,
                          style: const TextStyle(
                            color: ParentUi.dark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (library.ofKind(child.id, kind).isEmpty)
                          Text(
                            _emptyText[kind]!,
                            style: const TextStyle(color: ParentUi.muted),
                          )
                        else
                          for (final report in library.ofKind(child.id, kind))
                            ParentCard(
                              onTap: () => _open(report),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: ParentUi.purple,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.title,
                                          style: const TextStyle(
                                            color: ParentUi.dark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Updated ${formatDate(report.createdAt)}',
                                          style: const TextStyle(
                                            color: ParentUi.muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () => _delete(report),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: ParentUi.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}
