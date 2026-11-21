import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/core/api_client.dart';
import 'package:adhd/link/child_device.dart';
import 'package:adhd/sync/result_sync.dart';

class _FakeClient extends ApiClient {
  _FakeClient({this.fail = false});

  bool fail;
  final sent = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (fail) throw const ApiException('offline');
    sent.add({'path': path, ...body});
    return {'saved': true};
  }
}

void main() {
  const key = 'abcdefghijklmnopqrstuv';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ChildDevice.instance.link(5, '123456', syncKey: key);
  });

  test('a result is sent with the key when the phone is the child\'s', () async {
    final client = _FakeClient();
    final sync = ResultSync(client: client);

    await sync.sendIfLinked(
      childId: 5,
      kind: 'tova',
      takenAt: DateTime.fromMillisecondsSinceEpoch(1000),
      data: {'trials': 10},
    );

    expect(client.sent, hasLength(1));
    expect(client.sent.single['path'], '/api/sync/push');
    expect(client.sent.single['key'], key);
    expect(client.sent.single['id'], '1000');
    expect(client.sent.single['kind'], 'tova');
  });

  test('another child\'s result is not sent', () async {
    final client = _FakeClient();

    await ResultSync(client: client).sendIfLinked(
      childId: 6,
      kind: 'cars',
      takenAt: DateTime.now(),
      data: {},
    );

    expect(client.sent, isEmpty);
  });

  test('results played offline are sent later, once, in order', () async {
    final client = _FakeClient(fail: true);
    final sync = ResultSync(client: client);

    for (final ms in [1, 2]) {
      await sync.sendIfLinked(
        childId: 5,
        kind: 'tova',
        takenAt: DateTime.fromMillisecondsSinceEpoch(ms),
        data: {},
      );
    }
    expect(client.sent, isEmpty);

    client.fail = false;
    await sync.flush();
    await sync.flush();

    expect(client.sent.map((e) => e['id']), ['1', '2']);
  });

  test('sync keys are long enough for the server', () async {
    SharedPreferences.setMockInitialValues({});

    final first = await SyncKeys.forChild(1);
    expect(SyncKeys.valid.hasMatch(first), isTrue);
    expect(await SyncKeys.forChild(1), first);
    expect(await SyncKeys.forChild(2), isNot(first));
    expect(await SyncKeys.existing(3), isNull);
  });
}
