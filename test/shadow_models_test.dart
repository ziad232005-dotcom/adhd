import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/shadows/shadow_application.dart';
import 'package:adhd/shadows/shadow_models.dart';

void main() {
  group('ShadowListing', () {
    test('reads a complete listing', () {
      final listing = ShadowListing.fromJson({
        'id': 3,
        'name': ' Mona Hassan ',
        'governorate': 'Cairo',
        'yearsExperience': '5',
        'qualification': 'Bachelor’s degree',
        'university': 'Cairo University',
        'currentWorkplace': 'A school',
        'childExperience': '3–5 yrs',
        'adhdExperience': 'Some',
        'skills': ['Behavior support', 'Focus training'],
        'phone': '01000000000',
        'email': '',
      })!;

      expect(listing.name, 'Mona Hassan');
      expect(listing.skills, ['Behavior support', 'Focus training']);
      expect(listing.phone, '01000000000');
      expect(listing.email, isNull);
      expect(listing.hasContact, isTrue);
    });

    test('rejects data without an id or a name', () {
      expect(ShadowListing.fromJson({'name': 'A'}), isNull);
      expect(ShadowListing.fromJson({'id': 1, 'name': ' '}), isNull);
      expect(ShadowListing.fromJson('nope'), isNull);
    });

    test('missing fields get safe values', () {
      final listing = ShadowListing.fromJson({'id': 1, 'name': 'Sara'})!;
      expect(listing.skills, isEmpty);
      expect(listing.governorate, '');
      expect(listing.hasContact, isFalse);
    });
  });

  group('ShadowApplication', () {
    test('keeps its answers when saved and loaded', () {
      final app = ShadowApplication(
        fullName: 'Sara Ali',
        birthDate: DateTime(1998, 4, 2),
        mobile: '01000000000',
        email: 'sara@mail.com',
        governorate: 'Giza',
        skills: ['Social skills'],
        documents: {
          DocumentKind.degree.key: const ShadowDocument(
            kind: 'degree',
            fileName: 'degree.pdf',
            sizeBytes: 2048,
            path: '/tmp/degree.pdf',
          ),
        },
      );

      final loaded = ShadowApplication.fromJson(app.toJson());
      expect(loaded.fullName, 'Sara Ali');
      expect(loaded.birthDate, DateTime(1998, 4, 2));
      expect(loaded.skills, ['Social skills']);
      expect(loaded.hasDegree, isTrue);
      expect(loaded.documents['degree']!.fileName, 'degree.pdf');
    });

    test('a form without a degree is not complete', () {
      expect(ShadowApplication().hasDegree, isFalse);
    });

    test('a damaged draft gives an empty form instead of failing', () {
      final loaded = ShadowApplication.fromJson({'documents': 'oops'});
      expect(loaded.fullName, '');
      expect(loaded.documents, isEmpty);
    });
  });
}
