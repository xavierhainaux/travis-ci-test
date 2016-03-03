import 'dart:io';
import 'package:test/test.dart';
import 'package:project1/image_magick.dart' as im;
import 'package:project1/sox.dart' as sox;

const String s3AccessKey = 'AKIAJYXM3I5BMCT3DAWA';
const String s3PrivateKey = 'IzeRZBbn23MkVBHtvVX5hcFHp7Sr3y3tn0HXCGQu';

final awsEnvVariables = {
  'AWS_ACCESS_KEY_ID': s3AccessKey,
  'AWS_SECRET_ACCESS_KEY': s3PrivateKey
};

_copyToS3(String from, String to) async {
  ProcessResult result = await Process.run(
      'aws', ['s3', 'cp', from, to, '--recursive'],
      environment: awsEnvVariables);
  print('s3 stdout: ${result.stdout}');
  print('s3 stderr: ${result.stderr}');
}

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

  test('ffmpeg', () async {
    ProcessResult versionResult = await Process.run('ffmpeg', ['--version']);
    print('version ${versionResult.stdout}');
    print('version ${versionResult.stderr}');

    new Directory('lib/mojo').create(recursive: true);
    ProcessResult result = await Process
        .run('ffmpeg', ['-i', 'lib/mojo_explode.mov', 'lib/mojo/%3d.png']);
    print('stdout: ${result.stdout}');
    print('stderr: ${result.stderr}');

    print('copy to s3');
    await _copyToS3('lib/mojo', 's3://gaming1-html5/playground/mojo');
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
