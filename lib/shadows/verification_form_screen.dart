import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'certificate_details_screen.dart';
import 'shadow_files.dart';
import 'shadow_api.dart';
import 'shadow_application.dart';
import 'shadow_draft_store.dart';
import 'shadow_submitted_screen.dart';
import 'shadow_ui.dart';

/// The 5-step form a Shadow Teacher fills in to be listed for parents. It
/// needs no account. Progress is saved after every step, so the person can
/// come back. The admin reviews it before parents can see the teacher.
class VerificationFormScreen extends StatefulWidget {
  const VerificationFormScreen({super.key});

  @override
  State<VerificationFormScreen> createState() =>
      _VerificationFormScreenState();
}

class _VerificationFormScreenState extends State<VerificationFormScreen> {
  static const _stepTitles = [
    'Personal info',
    'Education',
    'Experience',
    'Certificates',
    'Review',
  ];

  static const _governorates = [
    'Cairo', 'Giza', 'Alexandria', 'Qalyubia', 'Sharqia', 'Dakahlia',
    'Gharbia', 'Monufia', 'Beheira', 'Kafr El-Sheikh', 'Damietta',
    'Port Said', 'Ismailia', 'Suez', 'North Sinai', 'South Sinai',
    'Faiyum', 'Beni Suef', 'Minya', 'Asyut', 'Sohag', 'Qena', 'Luxor',
    'Aswan', 'Red Sea', 'New Valley', 'Matrouh',
  ];

  static const _qualifications = [
    'Diploma',
    'Bachelor’s degree',
    'Master’s degree',
    'PhD',
  ];

  static const _years = [
    'Less than 1', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10+',
  ];

  static const _graduationYears = 40;

  static const _childExperienceOptions = [
    'Under 1 yr', '1–3 yrs', '3–5 yrs', '5+ yrs',
  ];

  static const _adhdOptions = ['None', 'Some', 'Extensive'];

  static const _skillOptions = [
    'Behavior support',
    'Visual schedules',
    'Sensory regulation',
    'Parent communication',
    'Social skills',
    'Focus training',
  ];

  final _store = ShadowDraftStore.instance;
  final _formKey = GlobalKey<FormState>();

  late final ShadowApplication _app;
  bool _sending = false;

  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _university = TextEditingController();
  final _faculty = TextEditingController();
  final _department = TextEditingController();
  final _currentWork = TextEditingController();
  final _previousWork = TextEditingController();
  final _customSkill = TextEditingController();

  int _step = 0;
  bool _confirmed = false;
  bool _showErrors = false;

  // Values that are not plain text fields.
  DateTime? _birthDate;
  String _governorate = '';
  String _qualification = '';
  String _graduationYear = '';
  String _yearsExperience = '';
  String _childExperience = '';
  String _adhd = '';
  final List<String> _skills = [];
  String? _photoPath;

  @override
  void initState() {
    super.initState();

    _app = _store.application;

    _name.text = _app.fullName;
    _mobile.text = _app.mobile;
    _email.text = _app.email;
    _university.text = _app.university;
    _faculty.text = _app.faculty;
    _department.text = _app.department;
    _currentWork.text = _app.currentWorkplace;
    _previousWork.text = _app.previousWorkplaces;

    _birthDate = _app.birthDate;
    _governorate = _app.governorate;
    _qualification = _app.qualification;
    _graduationYear = _app.graduationYear;
    _yearsExperience = _app.yearsExperience;
    _childExperience = _app.childExperience;
    _adhd = _app.adhdExperience;
    _skills.addAll(_app.skills);
    _photoPath = _app.photoPath;
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _university.dispose();
    _faculty.dispose();
    _department.dispose();
    _currentWork.dispose();
    _previousWork.dispose();
    _customSkill.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- saving

  void _saveFields() {
    _store.edit((app) {
      app.fullName = _name.text.trim();
      app.birthDate = _birthDate;
      app.mobile = _mobile.text.trim();
      app.email = _email.text.trim();
      app.governorate = _governorate;
      app.photoPath = _photoPath;
      app.qualification = _qualification;
      app.university = _university.text.trim();
      app.faculty = _faculty.text.trim();
      app.department = _department.text.trim();
      app.graduationYear = _graduationYear;
      app.yearsExperience = _yearsExperience;
      app.currentWorkplace = _currentWork.text.trim();
      app.previousWorkplaces = _previousWork.text.trim();
      app.childExperience = _childExperience;
      app.adhdExperience = _adhd;
      app.skills = List<String>.of(_skills);
    });
  }

  // --------------------------------------------------------- navigation

  bool _stepIsValid() {
    // Text fields use their validators.
    final textOk = _formKey.currentState?.validate() ?? true;

    switch (_step) {
      case 0:
        return textOk &&
            _birthDate != null &&
            _governorate.isNotEmpty;
      case 1:
        return textOk &&
            _qualification.isNotEmpty &&
            _graduationYear.isNotEmpty;
      case 2:
        return textOk && _yearsExperience.isNotEmpty;
      case 3:
        return _store.application.hasDegree;
      default:
        return true;
    }
  }

  void _next() {
    setState(() => _showErrors = true);

    if (!_stepIsValid()) {
      if (_step == 3) {
        ShadowUi.snack(
          context,
          'Upload your University Degree certificate (PDF) to continue.',
        );
      }
      return;
    }

    _saveFields();
    setState(() {
      _showErrors = false;
      _step++;
    });
  }

  void _back() {
    _saveFields();

    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _showErrors = false;
      _step--;
    });
  }

  void _goTo(int step) {
    _saveFields();
    setState(() {
      _showErrors = false;
      _step = step;
    });
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (!_confirmed) {
      ShadowUi.snack(context, 'Please confirm the declaration first.');
      return;
    }

    _saveFields();
    setState(() => _sending = true);

    try {
      final reference = await const ShadowApi().apply(_store.application);
      await _store.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ShadowSubmittedScreen(reference: reference),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) ShadowUi.snack(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ------------------------------------------------------------- photo

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _photoPath = file.path);
      }
    } catch (_) {
      if (mounted) {
        ShadowUi.snack(context, 'Could not open the photo gallery.');
      }
    }
  }

  // ------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return ShadowScaffold(
            title: 'Shadow Teacher',
            body: [
              _stepper(),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                autovalidateMode: _showErrors
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: _stepBody(),
              ),
            ],
            bottom: _step == 4
                ? ShadowActionBar(
                    label: _sending ? 'Sending...' : 'Submit for review',
                    onBack: _sending ? null : _back,
                    onPressed: _sending ? null : _submit,
                  )
                : ShadowActionBar(
                    label: 'Continue',
                    onBack: _back,
                    onPressed: _next,
                  ),
          );
        },
      ),
    );
  }

  Widget _stepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _stepTitles.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= _step
                        ? MazidColors.primary
                        : MazidColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_step + 1} of ${_stepTitles.length}',
              style: const TextStyle(
                color: MazidColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _stepTitles[_step],
              style: const TextStyle(
                color: MazidColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heading(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MazidColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: MazidColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _personal();
      case 1:
        return _education();
      case 2:
        return _experience();
      case 3:
        return _certificates();
      default:
        return _review();
    }
  }

  String? _requiredText(String? value, String message) =>
      MazidValidators.requiredText(value, message);

  // ------------------------------------------------------ step 1: personal

  Widget _personal() {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Personal information',
          'Exactly as shown on your national ID.',
        ),
        ShadowCard(
          child: Row(
            children: [
              ShadowAvatar(
                initials: _app.initials,
                size: 60,
                imagePath: _photoPath,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile photo',
                      style: TextStyle(
                        color: MazidColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'A clear photo of your face',
                      style: TextStyle(
                        color: MazidColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _pickPhoto,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: MazidColors.primary),
                ),
                child: Text(_photoPath == null ? 'Upload' : 'Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ShadowTextField(
          controller: _name,
          label: 'Full Name',
          hint: 'As on your ID',
          inputFormatters: MazidInputFormatters.name,
          validator: (v) =>
              MazidValidators.personName(v, 'Enter your full name'),
        ),
        const SizedBox(height: 14),
        ShadowDateField(
          label: 'Date of Birth',
          value: _birthDate,
          initialDate: DateTime(now.year - 28, now.month, now.day),
          firstDate: DateTime(1940),
          lastDate: DateTime(now.year - 18, now.month, now.day),
          errorText: _showErrors && _birthDate == null
              ? 'Select your date of birth (18 or older)'
              : null,
          onPicked: (d) => setState(() => _birthDate = d),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _mobile,
          label: 'Mobile Number',
          hint: '+20 1xx xxx xxxx',
          keyboardType: TextInputType.phone,
          textCapitalization: TextCapitalization.none,
          validator: (v) => _requiredText(v, 'Enter your mobile number'),
        ),
        const SizedBox(height: 6),
        const Text(
          'Phone verification will be added when SMS is available.',
          style: TextStyle(color: MazidColors.textMuted, fontSize: 11.5),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _email,
          label: 'Email Address',
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          validator: MazidValidators.email,
        ),
        const SizedBox(height: 14),
        ShadowDropdown(
          label: 'Governorate',
          value: _governorate,
          options: _governorates,
          hint: 'Select governorate',
          errorText: _showErrors && _governorate.isEmpty
              ? 'Select your governorate'
              : null,
          onChanged: (v) => setState(() => _governorate = v),
        ),
      ],
    );
  }

  // ------------------------------------------------------ step 2: education

  Widget _education() {
    final thisYear = DateTime.now().year;
    final years = [
      for (var i = 0; i < _graduationYears; i++) '${thisYear - i}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Education & qualifications',
          'Tell us about your highest degree.',
        ),
        ShadowDropdown(
          label: 'Highest Qualification',
          value: _qualification,
          options: _qualifications,
          errorText: _showErrors && _qualification.isEmpty
              ? 'Select your qualification'
              : null,
          onChanged: (v) => setState(() => _qualification = v),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _university,
          label: 'University / Institute',
          validator: (v) => _requiredText(v, 'Enter your university'),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _faculty,
          label: 'Faculty',
          validator: (v) => _requiredText(v, 'Enter your faculty'),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _department,
          label: 'Department',
          validator: (v) => _requiredText(v, 'Enter your department'),
        ),
        const SizedBox(height: 14),
        ShadowDropdown(
          label: 'Graduation Year',
          value: _graduationYear,
          options: years,
          errorText: _showErrors && _graduationYear.isEmpty
              ? 'Select your graduation year'
              : null,
          onChanged: (v) => setState(() => _graduationYear = v),
        ),
        const SizedBox(height: 18),
        const ShadowNote(
          'You’ll upload your degree certificate in step 4.',
        ),
      ],
    );
  }

  // ---------------------------------------------------- step 3: experience

  Widget _chipGroup({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MazidColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: selected == option,
                onSelected: (_) => onSelected(option),
                selectedColor: MazidColors.primary,
                labelStyle: TextStyle(
                  color: selected == option
                      ? Colors.white
                      : MazidColors.textBody,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                showCheckmark: false,
                shape: const StadiumBorder(
                  side: BorderSide(color: MazidColors.border),
                ),
                backgroundColor: Colors.white,
              ),
          ],
        ),
      ],
    );
  }

  void _addCustomSkill() {
    final value = _customSkill.text.trim();
    if (value.isEmpty) return;
    if (!_skills.contains(value)) setState(() => _skills.add(value));
    _customSkill.clear();
  }

  Widget _experience() {
    final allSkills = <String>{..._skillOptions, ..._skills}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Professional experience',
          'Help parents know your background.',
        ),
        ShadowDropdown(
          label: 'Years of Experience',
          value: _yearsExperience,
          options: _years,
          errorText: _showErrors && _yearsExperience.isEmpty
              ? 'Select your years of experience'
              : null,
          onChanged: (v) => setState(() => _yearsExperience = v),
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _currentWork,
          label: 'Current Workplace',
          hint: 'Optional',
          required: false,
        ),
        const SizedBox(height: 14),
        ShadowTextField(
          controller: _previousWork,
          label: 'Previous Workplaces',
          hint: 'Optional',
          required: false,
          maxLines: 3,
        ),
        const SizedBox(height: 18),
        _chipGroup(
          label: 'Experience with Children',
          options: _childExperienceOptions,
          selected: _childExperience,
          onSelected: (v) => setState(() => _childExperience = v),
        ),
        const SizedBox(height: 18),
        _chipGroup(
          label: 'ADHD Experience',
          options: _adhdOptions,
          selected: _adhd,
          onSelected: (v) => setState(() => _adhd = v),
        ),
        const SizedBox(height: 18),
        const Text(
          'Professional Skills',
          style: TextStyle(
            color: MazidColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in allSkills)
              FilterChip(
                label: Text(skill),
                selected: _skills.contains(skill),
                onSelected: (on) => setState(() {
                  if (on) {
                    _skills.add(skill);
                  } else {
                    _skills.remove(skill);
                  }
                }),
                selectedColor: MazidColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: _skills.contains(skill)
                      ? Colors.white
                      : MazidColors.textBody,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                shape: const StadiumBorder(
                  side: BorderSide(color: MazidColors.border),
                ),
                backgroundColor: Colors.white,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customSkill,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addCustomSkill(),
                decoration: const InputDecoration(hintText: 'Add a skill'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _addCustomSkill,
              style: IconButton.styleFrom(
                backgroundColor: MazidColors.primary,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------- step 4: certificates

  Future<void> _uploadCertificate(DocumentKind kind) async {
    PickedPdf? picked;

    try {
      picked = await ShadowFiles.pickPdf();
    } catch (error) {
      if (mounted) {
        ShadowUi.snack(context, 'Could not open the file picker ($error).');
      }
      return;
    }

    if (picked == null || !mounted) return;

    if (picked.sizeBytes > ShadowFiles.maxBytes) {
      ShadowUi.snack(context, 'The file is bigger than 10 MB.');
      return;
    }

    await _openDetails(
      ShadowDocument(
        kind: kind.key,
        fileName: picked.name,
        sizeBytes: picked.sizeBytes,
        path: picked.path,
        certificateName: kind.title,
      ),
    );
  }

  Future<void> _openDetails(ShadowDocument document) async {
    final result = await Navigator.push<ShadowDocument>(
      context,
      MaterialPageRoute(
        builder: (_) => CertificateDetailsScreen(document: document),
      ),
    );

    if (result != null) _store.setDocument(result);
  }

  Widget _certificates() {
    final docs = _store.application.documents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Upload certificates', 'PDF only • up to 10 MB each'),
        for (final kind in DocumentKind.all) ...[
          _DocumentCard(
            kind: kind,
            document: docs[kind.key],
            showMissing: _showErrors && kind.required && docs[kind.key] == null,
            onUpload: () => _uploadCertificate(kind),
            onEdit: () => _openDetails(docs[kind.key]!),
            onRemove: () => _store.removeDocument(kind.key),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        const ShadowNote.privacy(
          'Your documents are only seen by the MAZID admin, never by '
          'parents.',
        ),
      ],
    );
  }

  // ------------------------------------------------------ step 5: review

  Widget _summary(String title, int step, List<(String, String)> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShadowCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: MazidColors.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _goTo(step),
                  child: const Text('Edit'),
                ),
              ],
            ),
            for (final row in rows) ShadowInfoRow(row.$1, row.$2),
          ],
        ),
      ),
    );
  }

  Widget _review() {
    final app = _store.application;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Review & submit', 'Check everything before sending.'),
        _summary('Personal information', 0, [
          ('Name', app.fullName),
          ('Date of birth', ShadowUi.date(app.birthDate)),
          ('Mobile', app.mobile),
          ('Email', app.email),
          ('Governorate', app.governorate),
        ]),
        _summary('Education', 1, [
          ('Qualification', app.qualification),
          ('University', app.university),
          ('Faculty', app.faculty),
          ('Department', app.department),
          ('Graduated', app.graduationYear),
        ]),
        _summary('Experience', 2, [
          ('Years', app.yearsExperience),
          ('Current workplace', app.currentWorkplace),
          ('With children', app.childExperience),
          ('ADHD', app.adhdExperience),
          ('Skills', app.skills.join(', ')),
        ]),
        _summary('Certificates', 3, [
          for (final kind in DocumentKind.all)
            if (app.documents.containsKey(kind.key))
              (kind.title, app.documents[kind.key]!.fileName),
        ]),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => setState(() => _confirmed = !_confirmed),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _confirmed,
                activeColor: MazidColors.primary,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'I confirm that all information and uploaded documents '
                    'are accurate and belong to me. I agree that, if the '
                    'admin approves me, parents can see my name, details, '
                    'phone and email. My documents are seen only by the '
                    'admin.',
                    style: TextStyle(
                      color: MazidColors.textBody,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.kind,
    required this.document,
    required this.showMissing,
    required this.onUpload,
    required this.onEdit,
    required this.onRemove,
  });

  final DocumentKind kind;
  final ShadowDocument? document;
  final bool showMissing;
  final VoidCallback onUpload;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final doc = document;
    final uploaded = doc != null;

    return ShadowCard(
      borderColor: uploaded
          ? const Color(0xFFBFE6D3)
          : (showMissing ? MazidColors.error : MazidColors.border),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: uploaded
                  ? MazidColors.successSoft
                  : MazidColors.softPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: uploaded ? MazidColors.success : MazidColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind.title,
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (uploaded)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: MazidColors.success,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [doc.fileName, doc.sizeLabel]
                              .where((e) => e.isNotEmpty)
                              .join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MazidColors.success,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  kind.required
                      ? const ShadowBadge(
                          'Required',
                          color: MazidColors.pink,
                          background: MazidColors.pinkSoft,
                        )
                      : const ShadowBadge(
                          'Optional',
                          color: MazidColors.textMuted,
                          background: Color(0xFFF2F1F7),
                        ),
              ],
            ),
          ),
          if (uploaded) ...[
            IconButton(
              tooltip: 'Edit details',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_rounded, size: 16),
              label: const Text('PDF'),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(
                  color: MazidColors.primary,
                  width: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
