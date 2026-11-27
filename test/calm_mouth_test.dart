import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:adhd/child_calm.dart';

void main() {
  testWidgets('mouth painter repaints only when openness changes', (t) async {
    expect(const BreathMouthPainter(0.5).shouldRepaint(const BreathMouthPainter(0.5)), isFalse);
    expect(const BreathMouthPainter(0.5).shouldRepaint(const BreathMouthPainter(0.6)), isTrue);
  });

  testWidgets('calm screen shows the animated mouth', (t) async {
    await t.pumpWidget(const MaterialApp(home: CalmScreen()));
    await t.pump(const Duration(seconds: 2));
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is BreathMouthPainter), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
