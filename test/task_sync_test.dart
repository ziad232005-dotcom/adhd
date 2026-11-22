import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/child.dart';
import 'package:adhd/core/api_client.dart';
import 'package:adhd/link/child_device.dart';
import 'package:adhd/sync/task_sync.dart';

class _FakeClient extends ApiClient {
  _FakeClient({this.reply = const {}});

  Map<String, dynamic> reply;
  final sent = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    sent.add({'path': path, ...body});
    return reply;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = 'abcdefghijklmnopqrstuv';
  const content = {
    'tasks': [
      {'id': 1, 'title': 'Read', 'subtitle': '10 min', 'points': 5, 'minutes': null},
    ],
    'rewards': <Map<String, dynamic>>[],
    'nextTaskId': 2,
    'nextRewardId': 1,
  };

  setUp(() async {
    SharedPreferences.setMockInitialValues({'mazid_child_sync_3': key});
    await ChildDevice.instance.unlock('000000');
  });

  test('the parent sends the copy once, and again only when it changes',
      () async {
    final client = _FakeClient();
    final sync = TaskSync(client: client);

    expect(await sync.push(3, content), isTrue);
    expect(client.sent.single['path'], '/api/sync/tasks/put');
    expect(client.sent.single['key'], key);

    expect(await sync.push(3, content), isFalse);
    expect(client.sent, hasLength(1));
  });

  test('nothing is sent for a child without a key', () async {
    final client = _FakeClient();

    expect(await TaskSync(client: client).push(9, content), isFalse);
    expect(client.sent, isEmpty);
  });

  test('the child\'s phone applies the parent\'s newest tasks', () async {
    await ChildDevice.instance.link(3, '123456', syncKey: key);
    await ChildAppState.instance.loadData(childId: 3);

    final client = _FakeClient(
      reply: {'data': content, 'updatedAt': '2026-11-22T10:00:00Z'},
    );
    final sync = TaskSync(client: client);

    expect(await sync.pullIfLinked(), isTrue);
    expect(ChildAppState.instance.tasks.single.title, 'Read');

    // The same copy is not applied twice.
    expect(await sync.pullIfLinked(), isFalse);
  });

  test('a phone that is not the child\'s reads nothing', () async {
    final client = _FakeClient();

    expect(await TaskSync(client: client).pullIfLinked(), isFalse);
    expect(client.sent, isEmpty);
  });
}
