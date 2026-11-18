// Data types for the Shadow Teacher verification and the connection
// between a parent's child and a verified Shadow Teacher.

/// Which side of MAZID the signed-in person uses.
enum ShadowRole { parent, shadowTeacher }

/// Where a Shadow Teacher application is in the review process.
enum ApplicationStatus {
  draft('Draft'),
  pendingReview('Pending Review'),
  underVerification('Under Verification'),
  infoRequired('Additional Information Required'),
  verified('Verified'),
  rejected('Rejected');

  const ApplicationStatus(this.label);

  final String label;

  static ApplicationStatus fromName(String? name) {
    for (final status in values) {
      if (status.name == name) return status;
    }
    return ApplicationStatus.draft;
  }

  /// True while the admin team can still act on the application.
  bool get isOpen =>
      this == pendingReview ||
      this == underVerification ||
      this == infoRequired;
}

/// The kinds of documents a Shadow Teacher can upload.
class DocumentKind {
  const DocumentKind(this.key, this.title, {this.required = false});

  final String key;
  final String title;
  final bool required;

  static const degree =
      DocumentKind('degree', 'University Degree', required: true);

  static const all = <DocumentKind>[
    degree,
    DocumentKind('special_education', 'Special Education'),
    DocumentKind('adhd_training', 'ADHD Training'),
    DocumentKind('behavior_management', 'Behavior Management'),
    DocumentKind('child_protection', 'Child Protection'),
    DocumentKind('experience', 'Experience'),
  ];

  static String titleOf(String key) {
    for (final kind in all) {
      if (kind.key == key) return kind.title;
    }
    return key;
  }
}

/// One uploaded certificate (PDF) and its details.
class ShadowDocument {
  const ShadowDocument({
    required this.kind,
    required this.fileName,
    this.sizeBytes = 0,
    this.path,
    this.certificateName = '',
    this.issuer = '',
    this.obtainedOn,
    this.number = '',
  });

  final String kind;
  final String fileName;
  final int sizeBytes;
  final String? path;
  final String certificateName;
  final String issuer;
  final DateTime? obtainedOn;
  final String number;

  ShadowDocument copyWith({
    String? certificateName,
    String? issuer,
    DateTime? obtainedOn,
    String? number,
  }) {
    return ShadowDocument(
      kind: kind,
      fileName: fileName,
      sizeBytes: sizeBytes,
      path: path,
      certificateName: certificateName ?? this.certificateName,
      issuer: issuer ?? this.issuer,
      obtainedOn: obtainedOn ?? this.obtainedOn,
      number: number ?? this.number,
    );
  }

  String get sizeLabel {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).round()} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'fileName': fileName,
        'sizeBytes': sizeBytes,
        'path': path,
        'certificateName': certificateName,
        'issuer': issuer,
        'obtainedOn': obtainedOn?.toIso8601String(),
        'number': number,
      };

  factory ShadowDocument.fromJson(Map<String, dynamic> json) {
    return ShadowDocument(
      kind: json['kind'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      path: json['path'] as String?,
      certificateName: json['certificateName'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      obtainedOn: DateTime.tryParse(json['obtainedOn'] as String? ?? ''),
      number: json['number'] as String? ?? '',
    );
  }
}

/// The verification form of a Shadow Teacher and its review state.
class ShadowApplication {
  ShadowApplication({
    required this.id,
    this.fullName = '',
    this.birthDate,
    this.mobile = '',
    this.email = '',
    this.governorate = '',
    this.photoPath,
    this.qualification = '',
    this.university = '',
    this.faculty = '',
    this.department = '',
    this.graduationYear = '',
    this.yearsExperience = '',
    this.currentWorkplace = '',
    this.previousWorkplaces = '',
    this.childExperience = '',
    this.adhdExperience = '',
    List<String>? skills,
    Map<String, ShadowDocument>? documents,
    this.status = ApplicationStatus.draft,
    this.submittedAt,
    this.adminNote = '',
    List<String>? requestedItems,
    Set<String>? checklist,
    this.mobileVerified = false,
    this.available = true,
  })  : skills = skills ?? <String>[],
        documents = documents ?? <String, ShadowDocument>{},
        requestedItems = requestedItems ?? <String>[],
        checklist = checklist ?? <String>{};

  /// Shown to the person as "SH-2048".
  final String id;
  String fullName;
  DateTime? birthDate;
  String mobile;
  bool mobileVerified;

  /// A verified teacher can switch this off when they cannot take new
  /// children. Parents see it in the directory.
  bool available;
  String email;
  String governorate;
  String? photoPath;

  String qualification;
  String university;
  String faculty;
  String department;
  String graduationYear;

  String yearsExperience;
  String currentWorkplace;
  String previousWorkplaces;
  String childExperience;
  String adhdExperience;
  List<String> skills;

  Map<String, ShadowDocument> documents;

  ApplicationStatus status;
  DateTime? submittedAt;

  /// Message from the verification team (info request or rejection).
  String adminNote;
  List<String> requestedItems;

  /// Checks the reviewer ticked on the review screen.
  Set<String> checklist;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  bool get hasDegree => documents.containsKey(DocumentKind.degree.key);

  /// Parent-facing invite code, derived from the id.
  String get inviteCode => 'MZD-${id.replaceAll('SH-', '')}-TCH';

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'birthDate': birthDate?.toIso8601String(),
        'mobile': mobile,
        'mobileVerified': mobileVerified,
        'available': available,
        'email': email,
        'governorate': governorate,
        'photoPath': photoPath,
        'qualification': qualification,
        'university': university,
        'faculty': faculty,
        'department': department,
        'graduationYear': graduationYear,
        'yearsExperience': yearsExperience,
        'currentWorkplace': currentWorkplace,
        'previousWorkplaces': previousWorkplaces,
        'childExperience': childExperience,
        'adhdExperience': adhdExperience,
        'skills': skills,
        'documents': {
          for (final entry in documents.entries)
            entry.key: entry.value.toJson(),
        },
        'status': status.name,
        'submittedAt': submittedAt?.toIso8601String(),
        'adminNote': adminNote,
        'requestedItems': requestedItems,
        'checklist': checklist.toList(),
      };

  factory ShadowApplication.fromJson(Map<String, dynamic> json) {
    final docs = <String, ShadowDocument>{};
    final rawDocs = json['documents'];
    if (rawDocs is Map) {
      rawDocs.forEach((key, value) {
        if (value is Map) {
          docs['$key'] =
              ShadowDocument.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }

    List<String> strings(Object? value) =>
        value is List ? value.map((e) => '$e').toList() : <String>[];

    return ShadowApplication(
      id: json['id'] as String? ?? 'SH-0000',
      fullName: json['fullName'] as String? ?? '',
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
      mobile: json['mobile'] as String? ?? '',
      mobileVerified: json['mobileVerified'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      email: json['email'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
      qualification: json['qualification'] as String? ?? '',
      university: json['university'] as String? ?? '',
      faculty: json['faculty'] as String? ?? '',
      department: json['department'] as String? ?? '',
      graduationYear: json['graduationYear'] as String? ?? '',
      yearsExperience: json['yearsExperience'] as String? ?? '',
      currentWorkplace: json['currentWorkplace'] as String? ?? '',
      previousWorkplaces: json['previousWorkplaces'] as String? ?? '',
      childExperience: json['childExperience'] as String? ?? '',
      adhdExperience: json['adhdExperience'] as String? ?? '',
      skills: strings(json['skills']),
      documents: docs,
      status: ApplicationStatus.fromName(json['status'] as String?),
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
      adminNote: json['adminNote'] as String? ?? '',
      requestedItems: strings(json['requestedItems']),
      checklist: strings(json['checklist']).toSet(),
    );
  }
}

/// What a verified teacher looks like in the parent's directory.
/// It holds professional information only: no child data and no
/// private contact details.
class TeacherListing {
  const TeacherListing({
    required this.id,
    required this.name,
    required this.specialty,
    required this.yearsExperience,
    required this.training,
    required this.governorate,
    required this.qualification,
    required this.university,
    required this.graduationYear,
    required this.adhdExperience,
    required this.verifiedCertificates,
    this.email = '',
    this.inviteCode = '',
    this.available = true,
  });

  final String id;
  final String name;
  final String specialty;
  final String yearsExperience;
  final String training;
  final String governorate;
  final String qualification;
  final String university;
  final String graduationYear;
  final String adhdExperience;
  final List<String> verifiedCertificates;

  /// Used only to match an invitation; never shown to parents.
  final String email;
  final String inviteCode;

  /// Whether the teacher can take a new child right now.
  final bool available;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  String get experienceLabel => '$yearsExperience yrs exp.';

  factory TeacherListing.fromApplication(ShadowApplication app) {
    final kinds = app.documents.keys.map(DocumentKind.titleOf).toList();
    final training = app.documents.containsKey('adhd_training')
        ? 'ADHD Training'
        : (kinds.length > 1 ? kinds[1] : 'Qualified');

    return TeacherListing(
      id: app.id,
      name: app.fullName,
      specialty: app.department.isEmpty ? 'Special Education' : app.department,
      yearsExperience: app.yearsExperience,
      training: training,
      governorate: app.governorate,
      qualification: app.qualification,
      university: app.university,
      graduationYear: app.graduationYear,
      adhdExperience: app.adhdExperience,
      verifiedCertificates: kinds,
      email: app.email,
      inviteCode: app.inviteCode,
      available: app.available,
    );
  }
}

/// Parts of a child's information a teacher may see.
class SharePermission {
  const SharePermission(this.key, this.title, this.subtitle);

  final String key;
  final String title;
  final String subtitle;

  static const tasks = SharePermission(
    'tasks',
    'Tasks & daily activities',
    'Routines and completed tasks',
  );
  static const behavior = SharePermission(
    'behavior',
    'Focus & behavior',
    'Notes and focus sessions',
  );
  static const mood = SharePermission(
    'mood',
    'Mood check-ins',
    'How the child feels each day',
  );
  static const reports = SharePermission(
    'reports',
    'Weekly reports',
    'View and create reports',
  );

  static const all = <SharePermission>[tasks, behavior, mood, reports];

  static Map<String, bool> defaults() => {
        for (final p in all) p.key: p != reports,
      };
}

enum ConnectionStatus {
  /// Parent asked; the teacher has not answered.
  awaitingTeacher('Pending'),

  /// Teacher accepted; the parent must confirm access.
  awaitingParent('Accepted'),
  active('Active'),
  declined('Declined'),
  revoked('Revoked'),
  cancelled('Cancelled');

  const ConnectionStatus(this.label);

  final String label;

  static ConnectionStatus fromName(String? name) {
    for (final status in values) {
      if (status.name == name) return status;
    }
    return ConnectionStatus.awaitingTeacher;
  }

  bool get isLive =>
      this == awaitingTeacher || this == awaitingParent || this == active;
}

/// A link between one child and one verified teacher.
class TeacherConnection {
  TeacherConnection({
    required this.id,
    required this.teacherId,
    required this.childId,
    required this.parentName,
    required this.childName,
    required this.childAge,
    this.status = ConnectionStatus.awaitingTeacher,
    Map<String, bool>? permissions,
    DateTime? createdAt,
  })  : permissions = permissions ?? SharePermission.defaults(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String teacherId;
  final int childId;
  final String parentName;
  final String childName;
  final int childAge;
  ConnectionStatus status;
  Map<String, bool> permissions;
  DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'childId': childId,
        'parentName': parentName,
        'childName': childName,
        'childAge': childAge,
        'status': status.name,
        'permissions': permissions,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TeacherConnection.fromJson(Map<String, dynamic> json) {
    final perms = <String, bool>{};
    final raw = json['permissions'];
    if (raw is Map) {
      raw.forEach((key, value) => perms['$key'] = value == true);
    }

    return TeacherConnection(
      id: json['id'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      childId: json['childId'] as int? ?? 0,
      parentName: json['parentName'] as String? ?? '',
      childName: json['childName'] as String? ?? '',
      childAge: json['childAge'] as int? ?? 0,
      status: ConnectionStatus.fromName(json['status'] as String?),
      permissions: perms.isEmpty ? null : perms,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
