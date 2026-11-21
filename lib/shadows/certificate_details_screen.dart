import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'shadow_application.dart';
import 'shadow_ui.dart';

/// Details of one uploaded certificate. It is a full page (not a
/// dialog) so its text controllers are safe to dispose.
class CertificateDetailsScreen extends StatefulWidget {
  const CertificateDetailsScreen({super.key, required this.document});

  final ShadowDocument document;

  @override
  State<CertificateDetailsScreen> createState() =>
      _CertificateDetailsScreenState();
}

class _CertificateDetailsScreenState extends State<CertificateDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _issuer;
  late final TextEditingController _number;
  DateTime? _obtained;
  bool _dateError = false;

  @override
  void initState() {
    super.initState();
    final d = widget.document;
    _name = TextEditingController(text: d.certificateName);
    _issuer = TextEditingController(text: d.issuer);
    _number = TextEditingController(text: d.number);
    _obtained = d.obtainedOn;
  }

  @override
  void dispose() {
    _name.dispose();
    _issuer.dispose();
    _number.dispose();
    super.dispose();
  }

  void _save() {
    final valid = _formKey.currentState!.validate();
    setState(() => _dateError = _obtained == null);
    if (!valid || _obtained == null) return;

    Navigator.pop(
      context,
      widget.document.copyWith(
        certificateName: _name.text.trim(),
        issuer: _issuer.text.trim(),
        obtainedOn: _obtained,
        number: _number.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final now = DateTime.now();

    return ShadowScaffold(
      title: 'Certificate details',
      body: [
        Text(
          DocumentKind.titleOf(doc.kind),
          style: const TextStyle(
            color: MazidColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ShadowCard(
          color: MazidColors.successSoft,
          borderColor: MazidColors.successSoft,
          child: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: MazidColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MazidColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      [doc.sizeLabel, 'Uploaded']
                          .where((e) => e.isNotEmpty)
                          .join(' • '),
                      style: const TextStyle(
                        color: MazidColors.success,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            children: [
              ShadowTextField(
                controller: _name,
                label: 'Certificate Name',
                validator: (v) => MazidValidators.requiredText(
                  v,
                  'Enter the certificate name',
                ),
              ),
              const SizedBox(height: 14),
              ShadowTextField(
                controller: _issuer,
                label: 'Issuing Organization',
                validator: (v) => MazidValidators.requiredText(
                  v,
                  'Enter who issued it',
                ),
              ),
              const SizedBox(height: 14),
              ShadowDateField(
                label: 'Date Obtained',
                value: _obtained,
                initialDate: now,
                firstDate: DateTime(1970),
                lastDate: now,
                errorText: _dateError ? 'Select the date' : null,
                onPicked: (d) => setState(() {
                  _obtained = d;
                  _dateError = false;
                }),
              ),
              const SizedBox(height: 14),
              ShadowTextField(
                controller: _number,
                label: 'Certificate Number',
                hint: 'If available',
                required: false,
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const ShadowNote(
          'The verification team checks the issuer and number, so accurate '
          'details help your review go faster.',
        ),
      ],
      bottom: MazidPrimaryButton(
        label: 'Save certificate',
        onPressed: _save,
      ),
    );
  }
}
