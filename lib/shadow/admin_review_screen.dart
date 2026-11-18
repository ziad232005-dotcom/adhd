import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Admin: review one application, check the documents and decide.
class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  static const _checks = [
    'Identity matches certificate name',
    'Issuing body is recognised',
    'Certificate number checked',
    'Verified with issuer / official portal',
    'Date and year are consistent',
    'File is original and readable',
  ];

  final _store = ShadowStore.instance;
  final _note = TextEditingController();
  final _items = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Opening a new application starts its review. Notifying listeners
    // must not happen while this screen is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.startReview(widget.applicationId);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    _items.dispose();
    super.dispose();
  }

  void _decide(ApplicationStatus status) {
    final app = _store.applicationById(widget.applicationId);
    if (app == null) return;

    if (status == ApplicationStatus.verified &&
        app.checklist.length < _checks.length) {
      ShadowUi.snack(
        context,
        'Complete every check before verifying. A PDF alone does not '
        'prove a certificate is genuine.',
      );
      return;
    }

    final items = _items.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final problem = _store.decide(
      app.id,
      status,
      note: _note.text,
      requestedItems: status == ApplicationStatus.infoRequired ? items : [],
    );

    if (problem != null) {
      ShadowUi.snack(context, problem);
      return;
    }

    ShadowUi.snack(context, 'Decision saved: ${status.label}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final app = _store.applicationById(widget.applicationId);

        if (app == null) {
          return ShadowScaffold(
            title: 'Review',
            children: const [
              SizedBox(height: 40),
              Center(child: Text('Application not found.')),
            ],
          );
        }

        final decided = !app.status.isOpen;

        return ShadowScaffold(
          title: app.id,
          children: [
            Row(
              children: [
                ShadowAvatar(
                  initials: app.initials,
                  size: 52,
                  imagePath: app.photoPath,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.fullName,
                        style: const TextStyle(
                          color: MazidColors.textDark,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Submitted ${ShadowUi.shortDate(app.submittedAt)}',
                        style: const TextStyle(
                          color: MazidColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ShadowBadge.status(app.status),
              ],
            ),
            const SizedBox(height: 16),
            ShadowCard(
              child: Column(
                children: [
                  ShadowInfoRow('Date of birth', ShadowUi.date(app.birthDate)),
                  ShadowInfoRow('Mobile', app.mobile),
                  ShadowInfoRow('Email', app.email),
                  ShadowInfoRow('Governorate', app.governorate),
                  const Divider(height: 20),
                  ShadowInfoRow('Qualification', app.qualification),
                  ShadowInfoRow('University', app.university),
                  ShadowInfoRow('Faculty', app.faculty),
                  ShadowInfoRow('Department', app.department),
                  ShadowInfoRow('Graduated', app.graduationYear),
                  const Divider(height: 20),
                  ShadowInfoRow('Experience', '${app.yearsExperience} yrs'),
                  ShadowInfoRow('Workplace', app.currentWorkplace),
                  ShadowInfoRow('ADHD experience', app.adhdExperience),
                  ShadowInfoRow('Skills', app.skills.join(', ')),
                ],
              ),
            ),
            const ShadowSectionTitle('Documents'),
            if (app.documents.isEmpty)
              const ShadowNote.warning('No documents were uploaded.')
            else
              for (final doc in app.documents.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocumentTile(document: doc),
                ),
            const ShadowNote.privacy(
              'Documents are private. A PDF preview opens here once files '
              'are stored on the server.',
            ),
            if (!decided) ...[
              const ShadowSectionTitle('Verification checklist'),
              ShadowCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final check in _checks)
                      CheckboxListTile(
                        value: app.checklist.contains(check),
                        onChanged: (_) =>
                            _store.toggleChecklist(app.id, check),
                        activeColor: MazidColors.primary,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          check,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const ShadowNote.warning(
                'A PDF alone doesn’t prove a certificate is genuine. Confirm '
                'the issuer and number through an official method before '
                'verifying.',
              ),
              const ShadowSectionTitle('Decision'),
              TextField(
                controller: _note,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Note / reason (sent to the applicant)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _items,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Requested items, one per line (for request info)',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'A note is required for Request info and Reject.',
                style: TextStyle(color: MazidColors.textMuted, fontSize: 11.5),
              ),
              const SizedBox(height: 16),
              MazidPrimaryButton(
                label: 'Verify',
                onPressed: () => _decide(ApplicationStatus.verified),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MazidOutlineButton(
                      label: 'Request info',
                      borderColor: const Color(0xFFB7791F),
                      onPressed: () =>
                          _decide(ApplicationStatus.infoRequired),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MazidOutlineButton(
                      label: 'Reject',
                      borderColor: MazidColors.error,
                      onPressed: () => _decide(ApplicationStatus.rejected),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const ShadowSectionTitle('Decision'),
              ShadowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadowBadge.status(app.status),
                    if (app.adminNote.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(app.adminNote),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final ShadowDocument document;

  @override
  Widget build(BuildContext context) {
    final d = document;

    return ShadowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined,
                  color: MazidColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DocumentKind.titleOf(d.kind),
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                d.sizeLabel,
                style: const TextStyle(
                  color: MazidColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShadowInfoRow('File', d.fileName),
          ShadowInfoRow('Certificate', d.certificateName),
          ShadowInfoRow('Issuer', d.issuer),
          ShadowInfoRow('Obtained', ShadowUi.shortDate(d.obtainedOn)),
          ShadowInfoRow('Number', d.number),
        ],
      ),
    );
  }
}
