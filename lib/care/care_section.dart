import 'package:flutter/material.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import '../reports/weekly_report_screen.dart';
import 'care_stores.dart';
import 'daily_log_screen.dart';
import 'doctor_report_screen.dart';
import 'medications_screen.dart';
import 'school_notes_screen.dart';
import 'triggers_screen.dart';

/// "Care" block of a child's page: everyday logs and the doctor report.
class CareSection extends StatefulWidget {
  const CareSection({super.key, required this.child});

  final ParentChild child;

  @override
  State<CareSection> createState() => _CareSectionState();
}

class _CareSectionState extends State<CareSection> {
  @override
  void initState() {
    super.initState();
    loadChildRecords(widget.child.id);
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Tile(
          icon: Icons.medication_rounded,
          title: 'Medicines & appointments',
          onTap: () => _open(MedicationsScreen(child: child)),
        ),
        _Tile(
          icon: Icons.bedtime_rounded,
          title: 'Sleep & meals',
          onTap: () => _open(DailyLogScreen(child: child)),
        ),
        _Tile(
          icon: Icons.bolt_rounded,
          title: 'Triggers',
          onTap: () => _open(TriggersScreen(child: child)),
        ),
        _Tile(
          icon: Icons.insights_rounded,
          title: 'Weekly report (PDF)',
          onTap: () => _open(WeeklyReportScreen(child: child)),
        ),
        _Tile(
          icon: Icons.description_rounded,
          title: 'Doctor report',
          onTap: () => _open(DoctorReportScreen(child: child)),
        ),
        _Tile(
          icon: Icons.school_rounded,
          title: 'From school',
          onTap: () => _open(SchoolNotesScreen(child: child)),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ParentCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: ParentUi.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ParentUi.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: ParentUi.muted),
        ],
      ),
    );
  }
}
