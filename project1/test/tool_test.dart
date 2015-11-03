import 'dart:io';
import 'package:test/test.dart';
import 'package:project1/image_magick.dart' as im;
import 'package:project1/sox.dart' as sox;

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
    Process process = await Process.start('pngquant', ['lib/blackjack.png'],
        runInShell: true);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    //print(result.stderr);
    //print(result.stdout);
    return process.exitCode;
  });

  test('sox', () {
    String outputPath = 'test/audio/background.mp3';
    sox.convert('test/audio/background.wav', outputPath,
        channels: 2, sampleRate: 44100);

    File outputFile = new File(outputPath);
    expect(outputFile.existsSync(), isTrue);

    outputFile.deleteSync();
  });
}
