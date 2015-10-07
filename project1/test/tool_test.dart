
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

  test('pngquant', () async {
    ///home/travis/pngquant-2.5.0/bin/
    Process process = await Process.start('pngquant', ['lib/blackjack.png']);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    //print(result.stderr);
    //print(result.stdout);
    return process.exitCode;
  });
}