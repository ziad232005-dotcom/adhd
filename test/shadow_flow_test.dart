import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/parent/parent_store.dart';
import 'package:adhd/shadow/shadow_models.dart';
import 'package:adhd/shadow/shadow_store.dart';

ShadowApplication _fillValidApplication(ShadowStore store) {
  store.editMyApplication((app) {
    app.fullName = 'Mona Hassan Ali';
    app.birthDate = DateTime(1995, 3, 14);
    app.mobile = '+20 100 123 4567';
    app.email = 'mona.hassan@example.com';
    app.governorate = 'Giza';
    app.qualification = 'Bachelor’s degree';
    app.university = 'Cairo University';
    app.faculty = 'Education';
    app.department = 'Special Education';
    app.graduationYear = '2018';
    app.yearsExperience = '4';
  });

  store.setDocument(
    const ShadowDocument(
      kind: 'degree',
      fileName: 'degree.pdf',
      sizeBytes: 1200000,
      certificateName: 'Bachelor’s degree',
      issuer: 'Cairo University',
    ),
  );

  return store.myApplication!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ShadowStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    store = ShadowStore.instance;
    store.applications.clear();
    store.connections.clear();
    store.invitations.clear();
    store.ownApplicationId = null;
    store.role = null;
    await store.load();

    final parents = ParentStore.instance;
    parents.children.clear();
    parents.selectedChildIndex = 0;
    parents.addChild(
      name: 'Omar',
      birthDate: DateTime(2018, 5, 1),
      grade: 'Grade 3',
    );
  });

  group('Verification', () {
    test('a new application is a draft and cannot be sent while incomplete',
        () {
      final app = store.ensureApplication();

      expect(app.status, ApplicationStatus.draft);
      expect(store.submitMyApplication(), isNotNull);
      expect(store.myStatus, ApplicationStatus.draft);
    });

    test('the degree certificate is required', () {
      store.ensureApplication();
      _fillValidApplication(store);
      store.removeDocument('degree');

      expect(
        store.submitMyApplication(),
        'Upload your University Degree certificate (PDF).',
      );
    });

    test('a complete application is sent for review and then locked', () {
      store.ensureApplication();
      final app = _fillValidApplication(store);

      expect(store.submitMyApplication(), isNull);
      expect(app.status, ApplicationStatus.pendingReview);
      expect(app.submittedAt, isNotNull);

      store.editMyApplication((a) => a.fullName = 'Changed');
      expect(app.fullName, 'Mona Hassan Ali');
    });

    test('request-info and reject need a note; verify does not', () {
      store.ensureApplication();
      final app = _fillValidApplication(store);
      store.submitMyApplication();

      expect(
        store.decide(app.id, ApplicationStatus.rejected),
        isNotNull,
      );
      expect(
        store.decide(app.id, ApplicationStatus.infoRequired, note: '  '),
        isNotNull,
      );
      expect(app.status, ApplicationStatus.pendingReview);

      expect(
        store.decide(
          app.id,
          ApplicationStatus.infoRequired,
          note: 'Upload a clear copy',
          requestedItems: ['Degree'],
        ),
        isNull,
      );
      expect(app.status, ApplicationStatus.infoRequired);
      expect(app.requestedItems, ['Degree']);

      // The applicant may edit again and re-send.
      store.editMyApplication((a) => a.university = 'Cairo Univ.');
      expect(app.university, 'Cairo Univ.');
      expect(store.submitMyApplication(), isNull);
      expect(app.status, ApplicationStatus.pendingReview);

      expect(store.decide(app.id, ApplicationStatus.verified), isNull);
      expect(store.isVerifiedTeacher, isTrue);
    });

    test('a rejected application can be reopened', () {
      store.ensureApplication();
      final app = _fillValidApplication(store);
      store.submitMyApplication();
      store.decide(app.id, ApplicationStatus.rejected, note: 'Not clear');

      store.reopenMyApplication();

      expect(app.status, ApplicationStatus.draft);
      expect(app.adminNote, isEmpty);
      expect(app.fullName, 'Mona Hassan Ali');
    });

    test('an application survives saving and loading', () async {
      store.ensureApplication();
      final app = _fillValidApplication(store);
      store.setRole(ShadowRole.shadowTeacher);
      store.submitMyApplication();

      // Let the best-effort save finish, then load into clean state.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      store.applications.clear();
      store.ownApplicationId = null;
      store.role = null;
      await store.load();

      expect(store.role, ShadowRole.shadowTeacher);
      expect(store.myApplication?.id, app.id);
      expect(store.myApplication?.status, ApplicationStatus.pendingReview);
      expect(store.myApplication?.documents.keys, contains('degree'));
    });
  });

  group('Directory', () {
    test('only verified teachers are listed', () {
      store.ensureApplication();
      final app = _fillValidApplication(store);
      store.submitMyApplication();

      expect(store.listingById(app.id), isNull);

      store.decide(app.id, ApplicationStatus.verified);
      final listing = store.listingById(app.id);

      expect(listing, isNotNull);
      expect(listing!.name, 'Mona Hassan Ali');
      expect(listing.verifiedCertificates, contains('University Degree'));
    });

    test('finds a verified teacher by email or invite code', () {
      expect(store.findVerified('sarah.ahmed@example.com')?.name,
          'Sarah Ahmed');
      expect(store.findVerified('  SARAH.AHMED@example.com ')?.name,
          'Sarah Ahmed');
      expect(store.findVerified('MZD-1002-TCH')?.name, 'Nada Hossam');
      expect(store.findVerified('nobody@example.com'), isNull);
    });

    test('an unverified account is known but cannot be invited', () {
      // Sample application "Ahmed Samir" is still pending.
      expect(store.findVerified('ahmed@example.com'), isNull);
      expect(store.isKnownButUnverified('ahmed@example.com'), isTrue);
    });
  });

  group('Connections', () {
    test('request → accept → confirm → revoke', () {
      final child = ParentStore.instance.children.first;
      final teacher = store.findVerified('sarah.ahmed@example.com')!;

      final c = store.requestConnection(teacher, child);
      expect(c.status, ConnectionStatus.awaitingTeacher);
      expect(store.connectionsForChild(child.id), hasLength(1));

      // The parent cannot confirm before the teacher accepts.
      store.parentConfirm(c.id, SharePermission.defaults());
      expect(c.status, ConnectionStatus.awaitingTeacher);

      store.teacherAccept(c.id);
      expect(c.status, ConnectionStatus.awaitingParent);

      store.parentConfirm(c.id, {'tasks': true, 'behavior': false});
      expect(c.status, ConnectionStatus.active);
      expect(c.permissions['behavior'], isFalse);

      store.revoke(c.id);
      expect(c.status, ConnectionStatus.revoked);
      expect(store.connectionsForChild(child.id), isEmpty);
    });

    test('requesting the same teacher twice reuses the open request', () {
      final child = ParentStore.instance.children.first;
      final teacher = store.findVerified('sarah.ahmed@example.com')!;

      final first = store.requestConnection(teacher, child);
      final second = store.requestConnection(teacher, child);

      expect(second.id, first.id);
      expect(store.connections, hasLength(1));
    });

    test('a declined or cancelled request can be sent again', () {
      final child = ParentStore.instance.children.first;
      final teacher = store.findVerified('sarah.ahmed@example.com')!;

      final first = store.requestConnection(teacher, child);
      store.teacherDecline(first.id);
      expect(first.status, ConnectionStatus.declined);

      final again = store.requestConnection(teacher, child);
      expect(again.id, isNot(first.id));

      store.cancelRequest(again.id);
      expect(again.status, ConnectionStatus.cancelled);
    });

    test('a teacher sees only their own requests and only after acceptance '
        'children appear', () {
      store.ensureApplication();
      final app = _fillValidApplication(store);
      store.submitMyApplication();
      store.decide(app.id, ApplicationStatus.verified);

      final child = ParentStore.instance.children.first;
      final me = store.listingById(app.id)!;
      final sarah = store.findVerified('sarah.ahmed@example.com')!;

      final mine = store.requestConnection(me, child);
      store.requestConnection(sarah, child);

      expect(store.incomingRequests.map((c) => c.id), [mine.id]);
      expect(store.myChildren, isEmpty);

      store.teacherAccept(mine.id);
      expect(store.incomingRequests, isEmpty);
      expect(store.myChildren.single.status, ConnectionStatus.awaitingParent);
    });

    test('the child data a teacher gets before approval is minimal', () {
      final child = ParentStore.instance.children.first;
      final teacher = store.findVerified('sarah.ahmed@example.com')!;
      final c = store.requestConnection(teacher, child);

      expect(c.childName, 'Omar');
      expect(c.childAge, child.age);
      expect(c.permissions.keys, isNot(contains('contact')));
    });
  });

  group('Availability', () {
    test('a teacher marked unavailable shows as unavailable', () {
      final nada = store.directory.firstWhere((t) => t.id == 'SH-1002');
      expect(nada.available, isFalse);

      final sarah = store.directory.firstWhere((t) => t.id == 'SH-1001');
      expect(sarah.available, isTrue);
    });

    test('a request becomes overdue after the response window', () {
      final child = ParentStore.instance.children.first;
      final teacher = store.findVerified('sarah.ahmed@example.com')!;
      final c = store.requestConnection(teacher, child);

      expect(store.isOverdue(c), isFalse);

      store.simulateDelay(c.id);
      expect(store.isOverdue(c), isTrue);

      // Another request for the same child can run alongside it.
      final other = store.directory.firstWhere((t) => t.id == 'SH-1003');
      final second = store.requestConnection(other, child);
      expect(second.id, isNot(c.id));
      expect(store.connectionsForChild(child.id), hasLength(2));

      // Once accepted, a request is no longer overdue.
      store.teacherAccept(c.id);
      expect(store.isOverdue(c), isFalse);
    });

    test('availability only changes for a verified teacher', () {
      store.setMyAvailability(false);
      expect(store.myApplication, isNull);
    });
  });

  group('Invitations', () {
    ParentChild firstChild() => ParentStore.instance.children.first;

    test('a verified teacher gets a request straight away', () {
      final connection = store.inviteByEmail(
        'sarah.ahmed@example.com',
        firstChild(),
      );

      expect(connection, isNotNull);
      expect(connection!.teacherId, 'SH-1001');
      expect(store.invitations, isEmpty);
    });

    test('an unknown email waits as an invitation', () {
      final connection = store.inviteByEmail(
        'Teacher@School.com',
        firstChild(),
        schoolName: 'Future School',
      );

      expect(connection, isNull);
      expect(store.invitations, hasLength(1));
      expect(store.invitations.first.email, 'teacher@school.com');
      expect(store.invitations.first.schoolName, 'Future School');
      expect(store.connections, isEmpty);
    });

    test('the same email is not invited twice for one child', () {
      store.inviteByEmail('teacher@school.com', firstChild());
      store.inviteByEmail('teacher@school.com', firstChild());

      expect(store.invitations, hasLength(1));
      expect(store.invitationsForChild(firstChild().id), hasLength(1));
    });

    test('verification turns the invitation into a request', () {
      store.inviteByEmail('mona.hassan@example.com', firstChild());

      final app = _fillValidApplication(store);
      expect(store.invitationsForMe, hasLength(1));
      expect(store.submitMyApplication(), isNull);
      expect(store.connections, isEmpty);

      expect(store.decide(app.id, ApplicationStatus.verified), isNull);

      expect(store.invitations.first.status, InvitationStatus.converted);
      expect(store.connections, hasLength(1));
      expect(store.connections.first.teacherId, app.id);
      expect(store.incomingRequests, hasLength(1));
      expect(store.invitationsForMe, isEmpty);
    });

    test('a rejected teacher keeps the invitation waiting', () {
      store.inviteByEmail('mona.hassan@example.com', firstChild());

      final app = _fillValidApplication(store);
      store.submitMyApplication();
      store.decide(app.id, ApplicationStatus.rejected, note: 'No');

      expect(store.invitations.first.isWaiting, isTrue);
      expect(store.connections, isEmpty);
    });

    test('a cancelled invitation is not delivered', () {
      store.inviteByEmail('mona.hassan@example.com', firstChild());
      store.cancelInvitation(store.invitations.first.id);

      final app = _fillValidApplication(store);
      store.submitMyApplication();
      store.decide(app.id, ApplicationStatus.verified);

      expect(store.connections, isEmpty);
    });

    test('invitations survive being saved and loaded', () {
      final invitation = ShadowInvitation(
        id: 'I-1',
        email: 'a@b.com',
        childId: 1,
        childName: 'Omar',
        childAge: 8,
        parentName: 'Mona',
        schoolName: 'School',
      );

      final copy = ShadowInvitation.fromJson(invitation.toJson());

      expect(copy.email, 'a@b.com');
      expect(copy.schoolName, 'School');
      expect(copy.isWaiting, isTrue);
    });
  });

  group('Models', () {
    test('document size label', () {
      const small = ShadowDocument(kind: 'a', fileName: 'a.pdf', sizeBytes: 860 * 1024);
      const big = ShadowDocument(kind: 'a', fileName: 'a.pdf', sizeBytes: 3 * 1024 * 1024);
      const none = ShadowDocument(kind: 'a', fileName: 'a.pdf');

      expect(small.sizeLabel, '860 KB');
      expect(big.sizeLabel, '3.0 MB');
      expect(none.sizeLabel, isEmpty);
    });

    test('an application round-trips through JSON', () {
      final app = ShadowApplication(
        id: 'SH-2100',
        fullName: 'Mona Hassan Ali',
        birthDate: DateTime(1995, 3, 14),
        skills: ['Behavior support'],
        status: ApplicationStatus.infoRequired,
        adminNote: 'More please',
        requestedItems: ['Degree'],
        checklist: {'a'},
      );

      final copy = ShadowApplication.fromJson(app.toJson());

      expect(copy.id, 'SH-2100');
      expect(copy.initials, 'MH');
      expect(copy.birthDate, DateTime(1995, 3, 14));
      expect(copy.status, ApplicationStatus.infoRequired);
      expect(copy.requestedItems, ['Degree']);
      expect(copy.checklist, {'a'});
    });
  });
}
