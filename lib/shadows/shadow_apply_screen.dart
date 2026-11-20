import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_ui.dart';
import 'shadow_api.dart';
import 'shadow_models.dart';

/// The form a Shadow Teacher fills in to be listed for parents. It needs no
/// account: the admin checks the certificate and, if it is fine, parents
/// can see the teacher and the ways to reach them.
class ShadowApplyScreen extends StatefulWidget {
  const ShadowApplyScreen({super.key});

  @override
  State<ShadowApplyScreen> createState() => _ShadowApplyScreenState();
}

class _ShadowApplyScreenState extends State<ShadowApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _years = TextEditingController();
  final _education = TextEditingController();
  final _availability = TextEditingController();
  final _bio = TextEditingController();
  final _price = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();

  final Set<String> _focus = {};
  String? _certificate;
  String? _certificateName;
  bool _agreed = false;
  bool _sending = false;
  int? _reference;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _name, _city, _years, _education, _availability, _bio, //
      _price, _phone, _whatsapp, _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      imageQuality: 70,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _certificate = base64Encode(bytes);
      _certificateName = file.name;
      _error = null;
    });
  }

  String? _optional(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String? problem;
    if (_focus.isEmpty) {
      problem = 'Choose at least one area you work with.';
    } else if (_certificate == null) {
      problem = 'Add a photo of your certificate.';
    } else if ([_phone, _whatsapp, _email].every((c) => _optional(c) == null)) {
      problem = 'Give at least one way for parents to reach you.';
    } else if (!_agreed) {
      problem = 'Please agree to show your details to parents.';
    }
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final id = await const ShadowApi().apply(
        ShadowApplication(
          name: _name.text.trim(),
          city: _city.text.trim(),
          yearsExperience: int.parse(_years.text.trim()),
          focus: _focus.toList(),
          education: _education.text.trim(),
          availability: _availability.text.trim(),
          bio: _bio.text.trim(),
          certificateBase64: _certificate!,
          pricePerSession: int.tryParse(_price.text.trim()),
          phone: _optional(_phone),
          whatsapp: _optional(_whatsapp),
          email: _optional(_email),
        ),
      );
      if (mounted) setState(() => _reference = id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
    int? maxLength,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          decoration: _decoration(label),
        ),
      );

  static String? _requiredNumber(String? value, int max) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number < 0 || number > max) {
      return 'Enter a number from 0 to $max.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_reference != null) return _Done(reference: _reference!);

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Join as a Shadow Teacher'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              const Text(
                'You do not need an account. Fill this in once. After the '
                'admin checks your certificate, parents can find you and '
                'contact you directly.',
                style: TextStyle(color: ParentUi.muted, height: 1.45),
              ),
              const SizedBox(height: 16),
              _field(
                _name,
                'Full name',
                formatters: MazidInputFormatters.name,
                validator: (v) =>
                    MazidValidators.personName(v, 'Please enter your name.'),
              ),
              _field(
                _city,
                'City',
                validator: (v) => MazidValidators.requiredText(
                  v,
                  'Please enter your city.',
                ),
              ),
              _field(
                _years,
                'Years of experience',
                keyboard: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => _requiredNumber(v, 60),
              ),
              _field(
                _education,
                'Degree and field (for example: Special education)',
                validator: (v) => MazidValidators.requiredText(
                  v,
                  'Please enter your degree.',
                ),
              ),
              const Text(
                'Children you work with',
                style: TextStyle(
                  color: ParentUi.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final area in ShadowApplication.focusAreas)
                    FilterChip(
                      label: Text(area),
                      selected: _focus.contains(area),
                      onSelected: (on) => setState(() {
                        on ? _focus.add(area) : _focus.remove(area);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _availability,
                'When you are available (for example: weekdays after 2 PM)',
                validator: (v) => MazidValidators.requiredText(
                  v,
                  'Please say when you are available.',
                ),
              ),
              _field(
                _price,
                'Price per session in EGP (optional)',
                keyboard: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _field(
                _bio,
                'About you and how you work with children',
                maxLines: 4,
                maxLength: 500,
                validator: (v) {
                  if ((v ?? '').trim().length < 20) {
                    return 'Write at least 20 characters.';
                  }
                  return null;
                },
              ),
              const Text(
                'How parents can reach you (at least one)',
                style: TextStyle(
                  color: ParentUi.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _field(
                _phone,
                'Phone',
                keyboard: TextInputType.phone,
                validator: MazidValidators.optionalPhone,
              ),
              _field(
                _whatsapp,
                'WhatsApp number',
                keyboard: TextInputType.phone,
                validator: MazidValidators.optionalPhone,
              ),
              _field(
                _email,
                'Email',
                keyboard: TextInputType.emailAddress,
                validator: (v) => (v ?? '').trim().isEmpty
                    ? null
                    : MazidValidators.email(v),
              ),
              OutlinedButton.icon(
                onPressed: _pickCertificate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ParentUi.purple,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  _certificateName == null
                      ? 'Add a photo of your certificate'
                      : 'Certificate: $_certificateName',
                ),
              ),
              const Text(
                'Only the admin sees the certificate. Parents never do.',
                style: TextStyle(color: ParentUi.muted, fontSize: 12.5),
              ),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I agree that my name, details and contact methods are '
                  'shown to parents if I am approved.',
                  style: TextStyle(fontSize: 13.5),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              FilledButton(
                onPressed: _sending ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: ParentUi.purple,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                ),
                child: Text(_sending ? 'Sending...' : 'Send for review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.reference});

  final int reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: ParentUi.purple,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sent for review',
                style: TextStyle(
                  color: ParentUi.dark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your reference number is $reference. Once the admin '
                'approves your certificate, parents will see you in the '
                'Shadow Teachers list.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ParentUi.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: ParentUi.purple,
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
