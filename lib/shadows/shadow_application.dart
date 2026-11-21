import 'dart:convert';
import 'dart:io';

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

/// The Shadow Teacher's form. It is kept on the phone while the teacher
/// fills it in, and sent to the server when they submit it.
class ShadowApplication {
  ShadowApplication({
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
  })  : skills = skills ?? <String>[],
        documents = documents ?? <String, ShadowDocument>{};

  /// What a teacher can pick as professional skills.
  static const skillOptions = [
    'Behavior support',
    'Visual schedules',
    'Sensory regulation',
    'Parent communication',
    'Social skills',
    'Focus training',
  ];

  String fullName;
  DateTime? birthDate;
  String mobile;
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

  bool get hasDegree => documents.containsKey(DocumentKind.degree.key);

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'birthDate': birthDate?.toIso8601String(),
        'mobile': mobile,
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

    String text(String key) => json[key] as String? ?? '';

    return ShadowApplication(
      fullName: text('fullName'),
      birthDate: DateTime.tryParse(text('birthDate')),
      mobile: text('mobile'),
      email: text('email'),
      governorate: text('governorate'),
      photoPath: json['photoPath'] as String?,
      qualification: text('qualification'),
      university: text('university'),
      faculty: text('faculty'),
      department: text('department'),
      graduationYear: text('graduationYear'),
      yearsExperience: text('yearsExperience'),
      currentWorkplace: text('currentWorkplace'),
      previousWorkplaces: text('previousWorkplaces'),
      childExperience: text('childExperience'),
      adhdExperience: text('adhdExperience'),
      skills: [
        for (final item in json['skills'] as List<dynamic>? ?? [])
          if (item is String) item,
      ],
      documents: docs,
    );
  }
}
