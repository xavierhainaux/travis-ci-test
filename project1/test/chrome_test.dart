@TestOn('chrome')
import 'dart:html';
import 'package:test/test.dart';

main() {
  test('Test on chrome', () {
    print(window.navigator.userAgent);

    expect(window.navigator.dartEnabled, isFalse);
  });
}