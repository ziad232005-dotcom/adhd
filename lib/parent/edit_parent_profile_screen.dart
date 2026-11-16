import 'package:flutter/material.dart';

import '../core/widgets/mazid_widgets.dart';
import 'parent_store.dart';
import 'parent_ui.dart';

const List<String> kGenderOptions = ['Not specified', 'Female', 'Male'];

const List<String> kRelationshipOptions = [
  'Not specified',
  'Mother',
  'Father',
  'Guardian',
  'Other',
];

/// Full parent details: personal info, address and emergency contact.
class EditParentProfileScreen extends StatefulWidget {
  const EditParentProfileScreen({super.key});

  @override
  State<EditParentProfileScreen> createState() =>
      _EditParentProfileScreenState();
}

class _EditParentProfileScreenState extends State<EditParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = ParentStore.instance;

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyPhone;
  late String _gender;
  late String _relationship;

  @override
  void initState() {
    super.initState();
    final p = _store.profile;

    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
    _age = TextEditingController(text: p.age == null ? '' : '${p.age}');
    _city = TextEditingController(text: p.city);
    _address = TextEditingController(text: p.address);
    _emergencyName = TextEditingController(text: p.emergencyName);
    _emergencyPhone = TextEditingController(text: p.emergencyPhone);
    _gender = p.gender.isEmpty ? kGenderOptions.first : p.gender;
    _relationship =
        p.relationship.isEmpty ? kRelationshipOptions.first : p.relationship;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _age.dispose();
    _city.dispose();
    _address.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final ageText = _age.text.trim();

    _store.updateProfile(
      ParentProfile(
        name: _name.text.trim(),
        email: _store.profile.email,
        phone: _phone.text.trim(),
        age: ageText.isEmpty ? null : int.parse(ageText),
        gender: _gender == kGenderOptions.first ? '' : _gender,
        relationship:
            _relationship == kRelationshipOptions.first ? '' : _relationship,
        city: _city.text.trim(),
        address: _address.text.trim(),
        emergencyName: _emergencyName.text.trim(),
        emergencyPhone: _emergencyPhone.text.trim(),
      ),
    );

    Navigator.pop(context, true);
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: ParentUi.dark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Edit Profile'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            children: [
              _section('Personal information'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => MazidValidators.requiredText(
                  value,
                  'Please enter your name.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _store.profile.email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email (verified)',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: MazidValidators.optionalPhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final age = int.tryParse(text);
                  if (age == null || age < 18 || age > 99) {
                    return 'Age must be between 18 and 99.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: [
                  for (final option in kGenderOptions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship to the child',
                  prefixIcon: Icon(Icons.family_restroom_rounded),
                ),
                items: [
                  for (final option in kRelationshipOptions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _relationship = value);
                },
              ),
              _section('Address'),
              TextFormField(
                controller: _city,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              _section('Emergency contact'),
              TextFormField(
                controller: _emergencyName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Contact name',
                  prefixIcon: Icon(Icons.contact_emergency_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emergencyPhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact phone',
                  prefixIcon: Icon(Icons.phone_in_talk_outlined),
                ),
                validator: MazidValidators.optionalPhone,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: ParentUi.purple,
                  ),
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
