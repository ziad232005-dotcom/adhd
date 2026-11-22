import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd/link/parent_code_dialog.dart';

void main() {
  Future<void> open(WidgetTester tester, void Function(String?) done) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                done(await ParentCodeDialog.show(context, 'Leave')),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('returns the typed code and closes without errors', (tester) async {
    String? result;
    await open(tester, (v) => result = v);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(result, '123456');
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel returns null', (tester) async {
    String? result = 'unset';
    await open(tester, (v) => result = v);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
