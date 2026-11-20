import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/shadows/shadow_models.dart';

void main() {
  group('ShadowListing', () {
    test('reads a complete listing', () {
      final listing = ShadowListing.fromJson({
        'id': 3,
        'name': ' Mona Hassan ',
        'city': 'Cairo',
        'yearsExperience': 5,
        'focus': ['ADHD', 'Autism'],
        'education': 'Special education',
        'availability': 'Weekdays',
        'bio': 'I work with children.',
        'pricePerSession': 300,
        'phone': '01000000000',
        'whatsapp': '',
        'email': null,
      })!;

      expect(listing.name, 'Mona Hassan');
      expect(listing.focus, ['ADHD', 'Autism']);
      expect(listing.pricePerSession, 300);
      expect(listing.phone, '01000000000');
      expect(listing.whatsapp, isNull);
      expect(listing.hasContact, isTrue);
    });

    test('rejects data without an id or a name', () {
      expect(ShadowListing.fromJson({'name': 'A'}), isNull);
      expect(ShadowListing.fromJson({'id': 1, 'name': ' '}), isNull);
      expect(ShadowListing.fromJson('nope'), isNull);
    });

    test('missing optional fields get safe values', () {
      final listing = ShadowListing.fromJson({'id': 1, 'name': 'Sara'})!;
      expect(listing.focus, isEmpty);
      expect(listing.yearsExperience, 0);
      expect(listing.hasContact, isFalse);
    });
  });

  group('ShadowApplication', () {
    ShadowApplication application({String? phone, String? email}) =>
        ShadowApplication(
          name: 'Sara Ali',
          city: 'Giza',
          yearsExperience: 2,
          focus: const ['ADHD'],
          education: 'Psychology',
          availability: 'Evenings',
          bio: 'Patient and organized teacher.',
          certificateBase64: 'AAAA',
          phone: phone,
          email: email,
        );

    test('needs at least one way to be reached', () {
      expect(application().hasContact, isFalse);
      expect(application(phone: '01000000000').hasContact, isTrue);
      expect(application(email: 'a@b.com').hasContact, isTrue);
    });

    test('is sent with the certificate', () {
      final json = application(phone: '01000000000').toJson();
      expect(json['certificate'], 'AAAA');
      expect(json['phone'], '01000000000');
      expect(json['focus'], ['ADHD']);
    });
  });
}
