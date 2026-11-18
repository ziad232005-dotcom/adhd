import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../parent/parent_store.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'teacher_profile_screen.dart';

/// Directory of teachers the MAZID team has verified. It shows
/// professional information only.
class TeacherDirectoryScreen extends StatefulWidget {
  const TeacherDirectoryScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<TeacherDirectoryScreen> createState() =>
      _TeacherDirectoryScreenState();
}

class _TeacherDirectoryScreenState extends State<TeacherDirectoryScreen> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _filters(List<TeacherListing> all) {
    final places = all.map((e) => e.governorate).where((e) => e.isNotEmpty);
    return ['All', 'ADHD Training', ...{...places}];
  }

  List<TeacherListing> _visible(List<TeacherListing> all) {
    final text = _search.text.trim().toLowerCase();

    return all.where((t) {
      final matchesFilter = _filter == 'All' ||
          (_filter == 'ADHD Training'
              ? t.verifiedCertificates.contains('ADHD Training')
              : t.governorate == _filter);

      final matchesText = text.isEmpty ||
          t.name.toLowerCase().contains(text) ||
          t.specialty.toLowerCase().contains(text);

      return matchesFilter && matchesText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = ShadowStore.instance.directory;
    final list = _visible(all);

    return ShadowScaffold(
      title: 'Verified Shadow Teachers',
      children: [
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search by name or specialty',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final f in _filters(all))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    showCheckmark: false,
                    selectedColor: MazidColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _filter == f
                          ? Colors.white
                          : MazidColors.textBody,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(color: MazidColors.border),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${list.length} verified ${list.length == 1 ? 'teacher' : 'teachers'}',
          style: const TextStyle(
            color: MazidColors.textMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          const ShadowCard(
            child: Text(
              'No verified teachers match your search.',
              style: TextStyle(color: MazidColors.textMuted),
            ),
          ),
        for (final teacher in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TeacherCard(
              teacher: teacher,
              onOpen: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherProfileScreen(
                    teacher: teacher,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        const ShadowNote.warning(
          'Listed means MAZID reviewed their documents. It isn’t a '
          'guarantee of fit for every child.',
        ),
      ],
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher, required this.onOpen});

  final TeacherListing teacher;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShadowAvatar(initials: teacher.initials, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ShadowBadge.verified(label: 'Verified Shadow Teacher'),
                const SizedBox(height: 8),
                Text(
                  '${teacher.specialty} • ${teacher.experienceLabel}',
                  style: const TextStyle(
                    color: MazidColors.textBody,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  '${teacher.training} • ${teacher.governorate}',
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: MazidColors.primary),
        ],
      ),
    );
  }
}
