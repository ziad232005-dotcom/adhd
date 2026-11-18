import 'package:flutter/material.dart';

import 'shadow_models.dart';
import 'shadow_ui.dart';

/// Read-only view of a submitted application (for the applicant).
class ApplicationSummaryScreen extends StatelessWidget {
  const ApplicationSummaryScreen({super.key, required this.application});

  final ShadowApplication application;

  @override
  Widget build(BuildContext context) {
    final a = application;

    Widget card(String title, List<Widget> rows) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShadowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...rows,
            ],
          ),
        ),
      );
    }

    return ShadowScaffold(
      title: 'My application',
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Application ${a.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ShadowBadge.status(a.status),
          ],
        ),
        const SizedBox(height: 14),
        card('Personal information', [
          ShadowInfoRow('Name', a.fullName),
          ShadowInfoRow('Date of birth', ShadowUi.date(a.birthDate)),
          ShadowInfoRow('Mobile', a.mobile),
          ShadowInfoRow('Email', a.email),
          ShadowInfoRow('Governorate', a.governorate),
        ]),
        card('Education', [
          ShadowInfoRow('Qualification', a.qualification),
          ShadowInfoRow('University', a.university),
          ShadowInfoRow('Faculty', a.faculty),
          ShadowInfoRow('Department', a.department),
          ShadowInfoRow('Graduated', a.graduationYear),
        ]),
        card('Experience', [
          ShadowInfoRow('Years', a.yearsExperience),
          ShadowInfoRow('Current workplace', a.currentWorkplace),
          ShadowInfoRow('Previous workplaces', a.previousWorkplaces),
          ShadowInfoRow('With children', a.childExperience),
          ShadowInfoRow('ADHD', a.adhdExperience),
          ShadowInfoRow('Skills', a.skills.join(', ')),
        ]),
        card('Certificates', [
          for (final doc in a.documents.values)
            ShadowInfoRow(DocumentKind.titleOf(doc.kind), doc.fileName),
        ]),
      ],
    );
  }
}
