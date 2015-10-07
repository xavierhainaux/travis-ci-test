
import 'dart:io';
import 'package:test/test.dart';
import 'package:project1/image_magick.dart' as im;

main() {
  test('Should be ok', () {
    expect(1 == 1, isTrue);
  });

  test('Imagemagick', () {
    im.ImageInfo imageInfo = im.identify('lib/blackjack.png');

    expect(imageInfo.width, equals(301));
  });

  test('pngquant', () {
    ProcessResult result = Process.runSync('/home/travis/pngquant-2.5.0/bin/pngquant', ['lib/blackjack.png']);
    print(result.stderr);
    print(result.stdout);
  });
}