import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../parent/parent_ui.dart';
import 'shadow_api.dart';
import 'shadow_application.dart';
import 'shadow_models.dart';

/// The parent's list of approved Shadow Teachers, with their details and
/// ways to contact them. The parent contacts them directly, outside the app.
class ShadowDirectoryScreen extends StatefulWidget {
  const ShadowDirectoryScreen({super.key});

  @override
  State<ShadowDirectoryScreen> createState() => _ShadowDirectoryScreenState();
}

class _ShadowDirectoryScreenState extends State<ShadowDirectoryScreen> {
  late Future<List<ShadowListing>> _future;
  String? _focus;

  @override
  void initState() {
    super.initState();
    _future = const ShadowApi().approved();
  }

  void _reload() => setState(() => _future = const ShadowApi().approved());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Shadow Teachers'),
      body: SafeArea(
        child: FutureBuilder<List<ShadowListing>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              return _Message(
                text: error is ApiException
                    ? error.message
                    : 'Something went wrong. Try again.',
                onRetry: _reload,
              );
            }

            final all = snapshot.data ?? const <ShadowListing>[];
            final shown = _focus == null
                ? all
                : all.where((s) => s.skills.contains(_focus)).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                const Text(
                  'Teachers whose certificate the MAZID admin checked. '
                  'Contact them directly and agree on the details '
                  'yourself.',
                  style: TextStyle(color: ParentUi.muted, height: 1.45),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _focus == null,
                      onSelected: (_) => setState(() => _focus = null),
                    ),
                    for (final area in ShadowApplication.skillOptions)
                      ChoiceChip(
                        label: Text(area),
                        selected: _focus == area,
                        onSelected: (_) => setState(() => _focus = area),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'No Shadow Teachers here yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ParentUi.muted),
                    ),
                  ),
                for (final listing in shown) _ListingCard(listing: listing),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ParentUi.muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final ShadowListing listing;

  @override
  Widget build(BuildContext context) {
    final s = listing;

    return ParentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.name,
                  style: const TextStyle(
                    color: ParentUi.dark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: ParentUi.purple,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (s.governorate.isNotEmpty) s.governorate,
              if (s.yearsExperience.isNotEmpty)
                '${s.yearsExperience} years of experience',
            ].join(' | '),
            style: const TextStyle(color: ParentUi.muted, fontSize: 13),
          ),
          if (s.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final skill in s.skills)
                  Chip(
                    label: Text(skill, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          if (s.qualification.isNotEmpty)
            _line(
              'Degree',
              [s.qualification, if (s.university.isNotEmpty) s.university]
                  .join(', '),
            ),
          if (s.currentWorkplace.isNotEmpty)
            _line('Works at', s.currentWorkplace),
          if (s.childExperience.isNotEmpty)
            _line('With children', s.childExperience),
          if (s.adhdExperience.isNotEmpty) _line('ADHD', s.adhdExperience),
          if (s.hasContact) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            if (s.phone != null) _contact(context, 'Phone', s.phone!),
            if (s.whatsapp != null) _contact(context, 'WhatsApp', s.whatsapp!),
            if (s.email != null) _contact(context, 'Email', s.email!),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: value),
            ],
          ),
          style: const TextStyle(color: ParentUi.dark, height: 1.35),
        ),
      );

  Widget _contact(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(label, style: const TextStyle(color: ParentUi.muted)),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              color: ParentUi.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied.')),
            );
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
        ),
      ],
    );
  }
}
