/// A Shadow Teacher shown to parents in the directory.
class ShadowListing {
  const ShadowListing({
    required this.id,
    required this.name,
    required this.governorate,
    required this.yearsExperience,
    required this.qualification,
    required this.university,
    required this.currentWorkplace,
    required this.childExperience,
    required this.adhdExperience,
    required this.skills,
    this.phone,
    this.email,
  });

  final int id;
  final String name;
  final String governorate;
  final String yearsExperience;
  final String qualification;
  final String university;
  final String currentWorkplace;
  final String childExperience;
  final String adhdExperience;
  final List<String> skills;
  final String? phone;
  final String? email;

  bool get hasContact => phone != null || email != null;

  /// Returns null when [json] is not a usable listing.
  static ShadowListing? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;

    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) return null;

    String text(String key) {
      final value = json[key];
      return value is String ? value.trim() : '';
    }

    String? optional(String key) {
      final value = text(key);
      return value.isEmpty ? null : value;
    }

    return ShadowListing(
      id: id,
      name: name.trim(),
      governorate: text('governorate'),
      yearsExperience: text('yearsExperience'),
      qualification: text('qualification'),
      university: text('university'),
      currentWorkplace: text('currentWorkplace'),
      childExperience: text('childExperience'),
      adhdExperience: text('adhdExperience'),
      skills: [
        for (final item in json['skills'] as List<dynamic>? ?? [])
          if (item is String) item,
      ],
      phone: optional('phone'),
      email: optional('email'),
    );
  }
}
