import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../parent/parent_store.dart';
import 'shadow_models.dart';

/// State of the Shadow Teacher verification and of the teacher/child
/// connections.
///
/// Everything is kept on the device for now (SharedPreferences). The
/// public methods are the ones a backend will take over later: submit
/// an application, review it, find verified teachers, connect them to
/// a child.
class ShadowStore extends ChangeNotifier {
  ShadowStore._();

  static final ShadowStore instance = ShadowStore._();

  static const _storageKey = 'mazid_shadow_state_v1';

  ShadowRole? role;
  String? ownApplicationId;

  final List<ShadowApplication> applications = [];
  final List<TeacherConnection> connections = [];
  final List<ShadowInvitation> invitations = [];

  int _nextApplicationNumber = 2100;
  int _nextConnectionNumber = 1;
  int _nextInvitationNumber = 1;

  // ---------------------------------------------------------------- load

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;

        final roleName = json['role'] as String?;
        for (final value in ShadowRole.values) {
          if (value.name == roleName) role = value;
        }

        ownApplicationId = json['ownApplicationId'] as String?;
        _nextApplicationNumber = json['nextApplicationNumber'] as int? ?? 2100;
        _nextConnectionNumber = json['nextConnectionNumber'] as int? ?? 1;
        _nextInvitationNumber = json['nextInvitationNumber'] as int? ?? 1;

        applications
          ..clear()
          ..addAll(
            (json['applications'] as List? ?? const []).map(
              (e) => ShadowApplication.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );

        connections
          ..clear()
          ..addAll(
            (json['connections'] as List? ?? const []).map(
              (e) => TeacherConnection.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );

        invitations
          ..clear()
          ..addAll(
            (json['invitations'] as List? ?? const []).map(
              (e) => ShadowInvitation.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      }
    } catch (_) {
      // Damaged data: start clean rather than crash.
      applications.clear();
      connections.clear();
      invitations.clear();
    }

    // Example applications so the admin screens are not empty.
    if (applications.isEmpty) {
      applications.addAll(_sampleApplications());
    }

    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'role': role?.name,
          'ownApplicationId': ownApplicationId,
          'nextApplicationNumber': _nextApplicationNumber,
          'nextConnectionNumber': _nextConnectionNumber,
          'nextInvitationNumber': _nextInvitationNumber,
          'applications': applications.map((a) => a.toJson()).toList(),
          'connections': connections.map((c) => c.toJson()).toList(),
          'invitations': invitations.map((i) => i.toJson()).toList(),
        }),
      );
    } catch (_) {
      // Saving is best effort; the screen state is still correct.
    }
  }

  void _changed() {
    unawaited(_save());
    notifyListeners();
  }

  // ---------------------------------------------------------------- role

  void setRole(ShadowRole value) {
    role = value;
    _changed();
  }

  /// Forgets the role (used when the person signs out).
  void clearRole() {
    role = null;
    _changed();
  }

  // ---------------------------------------------------- own application

  ShadowApplication? get myApplication {
    for (final app in applications) {
      if (app.id == ownApplicationId) return app;
    }
    return null;
  }

  ApplicationStatus get myStatus =>
      myApplication?.status ?? ApplicationStatus.draft;

  bool get isVerifiedTeacher => myStatus == ApplicationStatus.verified;

  /// Creates the person's application, prefilled from their sign-up.
  ShadowApplication ensureApplication() {
    final existing = myApplication;
    if (existing != null) return existing;

    final profile = ParentStore.instance.profile;
    final app = ShadowApplication(
      id: 'SH-${_nextApplicationNumber++}',
      fullName: profile.name,
      email: profile.email,
      mobile: profile.phone,
      birthDate: profile.birthDate,
    );

    applications.insert(0, app);
    ownApplicationId = app.id;
    _changed();
    return app;
  }

  /// Edits the person's own application. Changes are only allowed while
  /// it is a draft or the team asked for more information.
  void editMyApplication(void Function(ShadowApplication app) change) {
    final app = ensureApplication();
    if (app.status != ApplicationStatus.draft &&
        app.status != ApplicationStatus.infoRequired) {
      return;
    }
    change(app);
    _changed();
  }

  /// A verified teacher says whether they can take new children.
  void setMyAvailability(bool value) {
    final app = myApplication;
    if (app == null || app.status != ApplicationStatus.verified) return;
    app.available = value;
    _changed();
  }

  /// Opens a rejected application again so it can be corrected and
  /// sent again.
  void reopenMyApplication() {
    final app = myApplication;
    if (app == null || app.status != ApplicationStatus.rejected) return;
    app.status = ApplicationStatus.draft;
    app.adminNote = '';
    app.requestedItems = [];
    app.checklist = <String>{};
    _changed();
  }

  void setDocument(ShadowDocument document) {
    editMyApplication((app) => app.documents[document.kind] = document);
  }

  void removeDocument(String kind) {
    editMyApplication((app) => app.documents.remove(kind));
  }

  /// Returns a message about what is missing, or null when complete.
  String? missingForSubmit(ShadowApplication app) {
    if (app.fullName.trim().isEmpty ||
        app.birthDate == null ||
        app.mobile.trim().isEmpty ||
        app.email.trim().isEmpty ||
        app.governorate.isEmpty) {
      return 'Complete your personal information first.';
    }
    if (app.qualification.isEmpty ||
        app.university.trim().isEmpty ||
        app.faculty.trim().isEmpty ||
        app.department.trim().isEmpty ||
        app.graduationYear.isEmpty) {
      return 'Complete your education details first.';
    }
    if (app.yearsExperience.isEmpty) {
      return 'Add your years of experience.';
    }
    if (!app.hasDegree) {
      return 'Upload your University Degree certificate (PDF).';
    }
    return null;
  }

  /// Sends the application to the verification team.
  String? submitMyApplication() {
    final app = myApplication;
    if (app == null) return 'Start your application first.';

    final problem = missingForSubmit(app);
    if (problem != null) return problem;

    app.status = ApplicationStatus.pendingReview;
    app.submittedAt = DateTime.now();
    app.adminNote = '';
    app.requestedItems = [];
    _changed();
    return null;
  }

  // -------------------------------------------------------------- admin

  /// All applications, newest first, optionally filtered by status.
  List<ShadowApplication> applicationsWith(ApplicationStatus? status) {
    final list = applications
        .where((a) => a.status != ApplicationStatus.draft)
        .where((a) => status == null || a.status == status)
        .toList();
    list.sort((a, b) => (b.submittedAt ?? DateTime(2000))
        .compareTo(a.submittedAt ?? DateTime(2000)));
    return list;
  }

  int countWith(ApplicationStatus status) =>
      applications.where((a) => a.status == status).length;

  ShadowApplication? applicationById(String id) {
    for (final app in applications) {
      if (app.id == id) return app;
    }
    return null;
  }

  void toggleChecklist(String id, String item) {
    final app = applicationById(id);
    if (app == null) return;
    if (!app.checklist.add(item)) app.checklist.remove(item);
    _changed();
  }

  void startReview(String id) {
    final app = applicationById(id);
    if (app == null || app.status != ApplicationStatus.pendingReview) return;
    app.status = ApplicationStatus.underVerification;
    _changed();
  }

  /// Records the admin decision. A note is required for "info required"
  /// and "rejected".
  String? decide(
    String id,
    ApplicationStatus status, {
    String note = '',
    List<String> requestedItems = const [],
  }) {
    final app = applicationById(id);
    if (app == null) return 'Application not found.';

    final needsNote = status == ApplicationStatus.infoRequired ||
        status == ApplicationStatus.rejected;
    if (needsNote && note.trim().isEmpty) {
      return 'Write a note for the applicant first.';
    }

    app.status = status;
    app.adminNote = note.trim();
    app.requestedItems = List<String>.of(requestedItems);
    if (status == ApplicationStatus.verified) _deliverInvitations(app);
    _changed();
    return null;
  }

  // ---------------------------------------------------------- directory

  /// Verified teachers a parent can browse. Professional details only.
  List<TeacherListing> get directory {
    final list = <TeacherListing>[..._sampleListings];

    for (final app in applications) {
      if (app.status == ApplicationStatus.verified) {
        list.add(TeacherListing.fromApplication(app));
      }
    }
    return list;
  }

  TeacherListing? listingById(String id) {
    for (final item in directory) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Finds a verified teacher by email or invite code.
  TeacherListing? findVerified(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return null;

    for (final item in directory) {
      if (item.email.toLowerCase() == text ||
          item.inviteCode.toLowerCase() == text) {
        return item;
      }
    }
    return null;
  }

  /// True when the text looks like an account that exists but has not
  /// been verified yet.
  bool isKnownButUnverified(String query) {
    final text = query.trim().toLowerCase();
    for (final app in applications) {
      if (app.status != ApplicationStatus.verified &&
          (app.email.toLowerCase() == text ||
              app.inviteCode.toLowerCase() == text)) {
        return true;
      }
    }
    return false;
  }

  // -------------------------------------------------------- invitations

  /// The parent invites someone by email.
  ///
  /// A verified teacher gets a normal connection request straight away.
  /// Anyone else (not registered yet, or still being verified) gets a
  /// waiting invitation that is delivered once they are verified.
  /// Returns the connection when one was created, otherwise null.
  TeacherConnection? inviteByEmail(
    String email,
    ParentChild child, {
    String schoolName = '',
  }) {
    final verified = findVerified(email);
    if (verified != null) return requestConnection(verified, child);

    final text = email.trim().toLowerCase();
    for (final i in invitations) {
      if (i.isWaiting && i.email == text && i.childId == child.id) return null;
    }

    final parent = ParentStore.instance.profile.name;
    invitations.add(
      ShadowInvitation(
        id: 'I-${_nextInvitationNumber++}',
        email: text,
        childId: child.id,
        childName: child.name,
        childAge: child.age,
        parentName: parent.isEmpty ? 'Parent' : parent,
        schoolName: schoolName.trim(),
      ),
    );
    _changed();
    return null;
  }

  List<ShadowInvitation> invitationsForChild(int childId) => invitations
      .where((i) => i.isWaiting && i.childId == childId)
      .toList();

  void cancelInvitation(String id) {
    for (final i in invitations) {
      if (i.id == id && i.isWaiting) i.status = InvitationStatus.cancelled;
    }
    _changed();
  }

  /// Invitations addressed to the signed-in person's email.
  List<ShadowInvitation> get invitationsForMe {
    final app = myApplication;
    final email = (app?.email ?? ParentStore.instance.profile.email)
        .trim()
        .toLowerCase();
    if (email.isEmpty) return const [];
    return invitations.where((i) => i.isWaiting && i.email == email).toList();
  }

  /// Turns waiting invitations for a newly verified teacher into requests.
  void _deliverInvitations(ShadowApplication app) {
    final email = app.email.trim().toLowerCase();
    final listing = TeacherListing.fromApplication(app);

    for (final i in invitations) {
      if (!i.isWaiting || i.email != email) continue;

      if (liveConnection(listing.id, i.childId) == null) {
        connections.add(
          TeacherConnection(
            id: 'C-${_nextConnectionNumber++}',
            teacherId: listing.id,
            childId: i.childId,
            parentName: i.parentName,
            childName: i.childName,
            childAge: i.childAge,
          ),
        );
      }
      i.status = InvitationStatus.converted;
    }
  }

  // -------------------------------------------------------- connections

  List<TeacherConnection> connectionsForChild(int childId) {
    return connections
        .where((c) => c.childId == childId && c.status.isLive)
        .toList();
  }

  TeacherConnection? connectionById(String id) {
    for (final c in connections) {
      if (c.id == id) return c;
    }
    return null;
  }

  TeacherConnection? liveConnection(String teacherId, int childId) {
    for (final c in connections) {
      if (c.teacherId == teacherId &&
          c.childId == childId &&
          c.status.isLive) {
        return c;
      }
    }
    return null;
  }

  /// The parent asks a verified teacher to join a child's team.
  /// Returns the connection (an existing one if already requested).
  TeacherConnection requestConnection(
    TeacherListing teacher,
    ParentChild child, {
    Map<String, bool>? permissions,
  }) {
    final existing = liveConnection(teacher.id, child.id);
    if (existing != null) return existing;

    final connection = TeacherConnection(
      id: 'C-${_nextConnectionNumber++}',
      teacherId: teacher.id,
      childId: child.id,
      parentName: ParentStore.instance.profile.name.isEmpty
          ? 'Parent'
          : ParentStore.instance.profile.name,
      childName: child.name,
      childAge: child.age,
      permissions: permissions,
    );

    connections.add(connection);
    _changed();
    return connection;
  }

  /// A request the teacher has not answered for this long counts as
  /// late, and the parent is offered to look for another teacher.
  static const Duration responseWindow = Duration(hours: 48);

  bool isOverdue(TeacherConnection c) {
    return c.status == ConnectionStatus.awaitingTeacher &&
        DateTime.now().difference(c.createdAt) >= responseWindow;
  }

  /// Demo only: pretend the request was sent days ago.
  void simulateDelay(String id) {
    final c = connectionById(id);
    if (c == null) return;
    c.createdAt = DateTime.now().subtract(responseWindow + const Duration(hours: 1));
    _changed();
  }

  void cancelRequest(String id) => _setStatus(id, ConnectionStatus.cancelled);

  void teacherAccept(String id) {
    final c = connectionById(id);
    if (c == null || c.status != ConnectionStatus.awaitingTeacher) return;
    _setStatus(id, ConnectionStatus.awaitingParent);
  }

  void teacherDecline(String id) {
    final c = connectionById(id);
    if (c == null || c.status != ConnectionStatus.awaitingTeacher) return;
    _setStatus(id, ConnectionStatus.declined);
  }

  /// The parent confirms access with the chosen permissions.
  void parentConfirm(String id, Map<String, bool> permissions) {
    final c = connectionById(id);
    if (c == null || c.status != ConnectionStatus.awaitingParent) return;
    c.permissions = Map<String, bool>.of(permissions);
    _setStatus(id, ConnectionStatus.active);
  }

  void updatePermissions(String id, Map<String, bool> permissions) {
    final c = connectionById(id);
    if (c == null) return;
    c.permissions = Map<String, bool>.of(permissions);
    _changed();
  }

  void revoke(String id) => _setStatus(id, ConnectionStatus.revoked);

  void _setStatus(String id, ConnectionStatus status) {
    final c = connectionById(id);
    if (c == null) return;
    c.status = status;
    _changed();
  }

  // --- the signed-in teacher's side

  List<TeacherConnection> get incomingRequests {
    final id = ownApplicationId;
    if (id == null) return const [];
    return connections
        .where((c) =>
            c.teacherId == id && c.status == ConnectionStatus.awaitingTeacher)
        .toList();
  }

  List<TeacherConnection> get myChildren {
    final id = ownApplicationId;
    if (id == null) return const [];
    return connections
        .where((c) =>
            c.teacherId == id &&
            (c.status == ConnectionStatus.awaitingParent ||
                c.status == ConnectionStatus.active))
        .toList();
  }

  // ------------------------------------------------------------- samples

  static const _sampleListings = <TeacherListing>[
    TeacherListing(
      id: 'SH-1001',
      name: 'Sarah Ahmed',
      specialty: 'Special Education',
      yearsExperience: '4',
      training: 'ADHD Training',
      governorate: 'Giza',
      qualification: 'Bachelor’s degree',
      university: 'Cairo University',
      graduationYear: '2018',
      adhdExperience: 'Extensive',
      verifiedCertificates: [
        'University Degree',
        'Special Education Diploma',
        'ADHD Training',
      ],
      email: 'sarah.ahmed@example.com',
      inviteCode: 'MZD-1001-TCH',
    ),
    TeacherListing(
      id: 'SH-1002',
      name: 'Nada Hossam',
      specialty: 'Behavior Support',
      yearsExperience: '6',
      training: 'Child Protection',
      governorate: 'Cairo',
      qualification: 'Master’s degree',
      university: 'Ain Shams University',
      graduationYear: '2016',
      adhdExperience: 'Extensive',
      verifiedCertificates: [
        'University Degree',
        'Behavior Management',
        'Child Protection',
      ],
      email: 'nada.hossam@example.com',
      inviteCode: 'MZD-1002-TCH',
      available: false,
    ),
    TeacherListing(
      id: 'SH-1003',
      name: 'Mariam Tarek',
      specialty: 'Early Intervention',
      yearsExperience: '3',
      training: 'ADHD Training',
      governorate: 'Alexandria',
      qualification: 'Bachelor’s degree',
      university: 'Alexandria University',
      graduationYear: '2020',
      adhdExperience: 'Some',
      verifiedCertificates: ['University Degree', 'ADHD Training'],
      email: 'mariam.tarek@example.com',
      inviteCode: 'MZD-1003-TCH',
    ),
  ];

  /// Example applications so the admin screens have something to review.
  static List<ShadowApplication> _sampleApplications() {
    ShadowApplication make(
      String id,
      String name,
      String university,
      String years,
      ApplicationStatus status,
      int daysAgo, {
      String note = '',
    }) {
      return ShadowApplication(
        id: id,
        fullName: name,
        birthDate: DateTime(1994, 5, 12),
        mobile: '+20 100 555 0100',
        mobileVerified: true,
        email: '${name.split(' ').first.toLowerCase()}@example.com',
        governorate: 'Cairo',
        qualification: 'Bachelor’s degree',
        university: university,
        faculty: 'Education',
        department: 'Special Education',
        graduationYear: '2017',
        yearsExperience: years,
        adhdExperience: 'Some',
        skills: ['Behavior support', 'Visual schedules'],
        documents: {
          'degree': ShadowDocument(
            kind: 'degree',
            fileName: 'degree_${id.toLowerCase()}.pdf',
            sizeBytes: 1200000,
            certificateName: 'Bachelor’s degree',
            issuer: university,
            obtainedOn: DateTime(2017, 7, 1),
          ),
        },
        status: status,
        submittedAt: DateTime.now().subtract(Duration(days: daysAgo)),
        adminNote: note,
      );
    }

    return [
      make('SH-2047', 'Ahmed Samir', 'Ain Shams University', '2',
          ApplicationStatus.pendingReview, 0),
      make('SH-2044', 'Nour Fathy', 'Alexandria University', '6',
          ApplicationStatus.underVerification, 1),
      make('SH-2041', 'Heba Mostafa', 'Helwan University', '8',
          ApplicationStatus.infoRequired, 2,
          note: 'Please upload a clear copy of your degree.'),
      make('SH-2036', 'Salma Yehia', 'Tanta University', '3',
          ApplicationStatus.verified, 5),
      make('SH-2031', 'Omar Khaled', 'Private institute', '1',
          ApplicationStatus.rejected, 6,
          note: 'We could not confirm the issuing organization.'),
    ];
  }
}
