import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adhd/link/child_device.dart';

void main() {
  test('checkCode accepts only the parent code and changes nothing', () async {
    SharedPreferences.setMockInitialValues({});
    await ChildDevice.instance.link(4, '123456');

    expect(ChildDevice.instance.checkCode('123456'), isTrue);
    expect(ChildDevice.instance.checkCode(' 123456 '), isTrue);
    expect(ChildDevice.instance.checkCode('654321'), isFalse);
    expect(ChildDevice.instance.isLinked, isTrue);

    expect(await ChildDevice.instance.unlock('123456'), isTrue);
    expect(ChildDevice.instance.checkCode('123456'), isFalse);
  });
}
