@TestOn('dartium')
import 'dart:html';
import 'package:test/test.dart';

main() {
  test('Test on dartium', () {
    print(window.navigator.userAgent);

    expect(window.navigator.dartEnabled, isTrue);
  });
}