import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import 'admin_review_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Admin: every Shadow Teacher application and its status.
/// Only reachable in demo mode until real admin accounts exist.
class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final _store = ShadowStore.instance;
  final _search = TextEditingController();

  ApplicationStatus? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ShadowApplication> _visible() {
    final text = _search.text.trim().toLowerCase();

    return _store.applicationsWith(_filter).where((a) {
      if (text.isEmpty) return true;
      return a.fullName.toLowerCase().contains(text) ||
          a.id.toLowerCase().contains(text) ||
          a.university.toLowerCase().contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final list = _visible();

        return ShadowScaffold(
          title: 'Applications',
          body: [
            const Text(
              'Shadow Teacher applications',
              style: TextStyle(
                color: MazidColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review qualifications before anyone can access a child.',
              style: TextStyle(color: MazidColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(
                  'Pending',
                  _store.countWith(ApplicationStatus.pendingReview),
                  ApplicationStatus.pendingReview,
                ),
                const SizedBox(width: 10),
                _Stat(
                  'Verifying',
                  _store.countWith(ApplicationStatus.underVerification),
                  ApplicationStatus.underVerification,
                ),
                const SizedBox(width: 10),
                _Stat(
                  'More info',
                  _store.countWith(ApplicationStatus.infoRequired),
                  ApplicationStatus.infoRequired,
                ),
                const SizedBox(width: 10),
                _Stat(
                  'Verified',
                  _store.countWith(ApplicationStatus.verified),
                  ApplicationStatus.verified,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name, ID or university',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  for (final status in ApplicationStatus.values)
                    if (status != ApplicationStatus.draft)
                      _FilterChip(
                        label: status == ApplicationStatus.infoRequired
                            ? 'Additional Info'
                            : status.label,
                        selected: _filter == status,
                        onTap: () => setState(() => _filter = status),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (list.isEmpty)
              const ShadowCard(
                child: Text(
                  'No applications match.',
                  style: TextStyle(color: MazidColors.textMuted),
                ),
              )
            else
              for (final app in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ApplicationTile(app: app),
                ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.count, this.status);

  final String label;
  final int count;
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = ShadowUi.statusColors(status);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: fg,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: MazidColors.textBody,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: MazidColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : MazidColors.textBody,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        shape: const StadiumBorder(
          side: BorderSide(color: MazidColors.border),
        ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.app});

  final ShadowApplication app;

  @override
  Widget build(BuildContext context) {
    final docs = app.documents.length;

    return ShadowCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminReviewScreen(applicationId: app.id),
        ),
      ),
      child: Row(
        children: [
          ShadowAvatar(initials: app.initials, imagePath: app.photoPath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.fullName.isEmpty ? app.id : app.fullName,
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.id} • ${app.qualification} • ${app.university}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.yearsExperience} yrs • $docs ${docs == 1 ? 'file' : 'files'} • ${ShadowUi.shortDate(app.submittedAt)}',
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: ShadowBadge.status(app.status),
            ),
          ),
        ],
      ),
    );
  }
}
