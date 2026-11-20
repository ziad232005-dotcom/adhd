/// A Shadow Teacher shown to parents in the directory.
class ShadowListing {
  const ShadowListing({
    required this.id,
    required this.name,
    required this.city,
    required this.yearsExperience,
    required this.focus,
    required this.education,
    required this.availability,
    required this.bio,
    this.pricePerSession,
    this.phone,
    this.whatsapp,
    this.email,
  });

  final int id;
  final String name;
  final String city;
  final int yearsExperience;
  final List<String> focus;
  final String education;
  final String availability;
  final String bio;

  /// In Egyptian pounds, or null when the teacher did not give a price.
  final int? pricePerSession;
  final String? phone;
  final String? whatsapp;
  final String? email;

  bool get hasContact => [phone, whatsapp, email].any((c) => c != null);

  /// Returns null when [json] is not a complete listing.
  static ShadowListing? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;

    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) return null;

    String? text(String key) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    return ShadowListing(
      id: id,
      name: name.trim(),
      city: text('city') ?? '',
      yearsExperience: json['yearsExperience'] as int? ?? 0,
      focus: [
        for (final item in json['focus'] as List<dynamic>? ?? [])
          if (item is String) item,
      ],
      education: text('education') ?? '',
      availability: text('availability') ?? '',
      bio: text('bio') ?? '',
      pricePerSession: json['pricePerSession'] as int?,
      phone: text('phone'),
      whatsapp: text('whatsapp'),
      email: text('email'),
    );
  }
}

/// What a Shadow Teacher sends to be listed. The admin must approve it
/// before parents can see it.
class ShadowApplication {
  const ShadowApplication({
    required this.name,
    required this.city,
    required this.yearsExperience,
    required this.focus,
    required this.education,
    required this.availability,
    required this.bio,
    required this.certificateBase64,
    this.pricePerSession,
    this.phone,
    this.whatsapp,
    this.email,
  });

  /// What a teacher can say they work with.
  static const focusAreas = [
    'ADHD',
    'Autism',
    'Learning difficulties',
    'Speech delay',
    'Behavior support',
  ];

  final String name;
  final String city;
  final int yearsExperience;
  final List<String> focus;
  final String education;
  final String availability;
  final String bio;
  final String certificateBase64;
  final int? pricePerSession;
  final String? phone;
  final String? whatsapp;
  final String? email;

  /// At least one way for a parent to reach the teacher.
  bool get hasContact => [phone, whatsapp, email].any((c) => c != null);

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'yearsExperience': yearsExperience,
        'focus': focus,
        'education': education,
        'availability': availability,
        'bio': bio,
        'pricePerSession': pricePerSession,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'certificate': certificateBase64,
      };
}
