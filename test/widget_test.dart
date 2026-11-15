import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/core/mazid_theme.dart';
import 'package:adhd/main.dart';

/// Pumps the app on a phone-sized surface (390 x 844 logical pixels).
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ADHDCompanionApp());
}

void main() {
  testWidgets('Welcome screen shows the brand and both entry buttons',
      (tester) async {
    await pumpApp(tester);

    expect(find.text(MazidBrand.name), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Get Started opens the sign-up form', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
  });

  testWidgets('Sign In opens the login form', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Login form validates an empty email', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Please enter your email.'), findsOneWidget);
  });
}
