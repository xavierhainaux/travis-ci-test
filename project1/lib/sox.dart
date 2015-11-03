library asset_loader.src.backend.tool.sox;

import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final Logger _logger = new Logger('sox');

// Documentation: http://sox.sourceforge.net/sox.html

convert(String inputPath, String outputPath,
        {int channels, int sampleSize, int sampleRate}) {
  List args = [];

  args.add(inputPath);

  if (channels != null) {
    args.add('-c');
    args.add('$channels');
  }

  if (sampleSize != null) {
    args.add('-b');
    args.add('$sampleSize');
  }

  if (sampleRate != null) {
    args.add('-r');
    args.add('$sampleRate');
  }

  args.add(outputPath);

  // S'assurer que les dossiers existe car sinon ça fait planter sox
  new Directory(p.dirname(outputPath)).createSync(recursive: true);

  _execute(_SOX_EXECUTABLE, args);

  _checkOutputFileExists(outputPath, moreInfo: args.toString());
}

_checkOutputFileExists(String outputPath, {String moreInfo: ''}) {
  File outputFile = new File(outputPath);
  if (!outputFile.existsSync() || outputFile.lengthSync() == 0) {
    throw 'sox has not created file $outputPath ($moreInfo)';
  }
}

//TODO(xha): plutot que de recevoir les paramètres channels, sampleRate etc...
// essayer de les déterminer tout seul et de prendre le plus grand dénominateur
// commun
//TODO(xha): supporter un "multiPack" qui crèerais automatiquement plusieurs
// pack en groupant selon le nombre de channel.
List<AudioPackEntry> pack(List<String> inputPaths, String outputPath,
                          {Duration padding: const Duration(milliseconds: 100),
                          int channels: 2,
                          int sampleSize: 16,
                          int sampleRate: 48000}) {
  Directory tempDir = Directory.systemTemp.createTempSync();

  String outExtension = p.extension(outputPath);

  List<AudioPackEntry> result = [];
  Duration startTime = Duration.ZERO;

  try {
    int i = 0;
    List packArgs = [];
    for (String inputPath in inputPaths) {
      String normalizedPath = p.join(tempDir.path, '$i$outExtension');

      _execute(_SOX_EXECUTABLE, [
        inputPath,
        '-c',
        '$channels',
        //TODO(xha): vérifier si il faut aussi normalizer le sampleSize
        //'-b',
        //'$sampleSize',
        '-r',
        '$sampleRate',
        normalizedPath,
        'pad',
        '0',
        (padding.inMilliseconds / 1000).toStringAsFixed(3)
      ]);

      SoundInfo normalizedAudioInfo = info(normalizedPath);

      int durationInMs =
      normalizedAudioInfo.duration.inMilliseconds - padding.inMilliseconds;

      AudioPackEntry entry = new AudioPackEntry(
          inputPath, startTime, new Duration(milliseconds: durationInMs));
      result.add(entry);

      startTime += normalizedAudioInfo.duration;

      packArgs.add(normalizedPath);

      ++i;
    }

    packArgs.add(outputPath);

    _execute(_SOX_EXECUTABLE, packArgs);

    _checkOutputFileExists(outputPath, moreInfo: packArgs.toString());
  } finally {
    tempDir.deleteSync(recursive: true);
  }

  return result;
}

bool isMonoOrDualMono(String inputPath) {
  if (info(inputPath).channels < 2) return true;

  String result =
  _execute(_SOX_EXECUTABLE, [inputPath, '-n', 'remix', '1,2i', 'stats']);

  //TODO(xha): vérifier si ça marche réellement dans des cas intéressants
  //TODO(xha): améliorer le parsing du résultat et faire quelque chose de plus
  // solide qui risque moins d'être breaké à la première mise à jour.
  return result.contains(new RegExp(r'RMS Pk dB[ ]+\0.00')) ||
  result.contains(new RegExp(r'Pk lev dB[ ]+\-inf'));
}

SoundInfo info(String inputPath) {
  // Exemple de résultat de résultat pour: soxi transition.wav
  //Input File     : 'transition.wav'
  //Channels       : 2
  //Sample Rate    : 44100
  //Precision      : 16-bit
  //Duration       : 00:00:04.60 = 202752 samples = 344.816 CDDA sectors
  //File Size      : 812k
  //Bit Rate       : 1.41M
  //Sample Encoding: 16-bit Signed Integer PCM

  String result = _execute(_SOX_EXECUTABLE, ['--i', inputPath]);
  return parseSoundInfo(result);
}

SoundInfo parseSoundInfo(String input) {
  Map<String, String> infos = {};
  for (String entry in new LineSplitter().convert(input)) {
    int separatorIndex = entry.indexOf(':');
    if (separatorIndex > 0) {
      String key = entry.substring(0, separatorIndex).trim();
      String value = entry.substring(separatorIndex + 1).trim();

      infos[key] = value;
    }
  }

  if (infos.length < 7) {
    throw "Le fichier son n'a pas pu être identifié correctement";
  }

  return new SoundInfo(
      int.parse(infos['Channels']),
      int.parse(infos['Sample Rate']),
      _parseSampleSize(infos['Precision']),
      _parseDuration(infos['Duration']),
      _parseSize(infos['Bit Rate']));
}

int _parseSampleSize(String sampleSize) {
  if (sampleSize.endsWith('-bit')) {
    return int.parse(sampleSize.split('-bit')[0]);
  } else {
    return 0;
  }
}

Duration _parseDuration(String input) {
  String durationString = input.split('=')[0].trim();

  List parts = durationString.split(':');

  return new Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      milliseconds: (double.parse(parts[2]) * 1000).toInt());
}

int _parseSize(String size) {
  String lastChar = size[size.length - 1].toLowerCase();
  int mul = 1;
  if (lastChar == 'k') {
    mul = 1000;
  } else if (lastChar == 'm') {
    mul = 1000000;
  }

  return (double.parse(size.substring(0, size.length - 1)) * mul).toInt();
}

class SoundInfo {
  final int channels;
  final int sampleRate;
  final int sampleSize;
  final Duration duration;
  final int bitRate;

  SoundInfo(this.channels, this.sampleRate, this.sampleSize, this.duration,
            this.bitRate);
}

class AudioPackEntry {
  final Duration startTime;
  final Duration duration;
  final String inputPath;

  AudioPackEntry(this.inputPath, this.startTime, this.duration);
}

// Pour installer sox sur Mac avec le support pour mp3 & ogg:
// Utiliser homebrew
// brew install sox --with-lame --with-libvorbis
// ou
// installer lame & vorbis-tool avant d'installer sox
// brew install lame
// brew install vorbis-tool
// brew install sox
final String _SOX_EXECUTABLE = Platform.isMacOS ? '/usr/local/bin/sox' : 'sox';

String _execute(String process, List args) {
  // Sur MacOS, on doit mettre runInShell pour que ça marche (raison?)
  ProcessResult processResult =
  Process.runSync(process, args, runInShell: true);
  String stderr = processResult.stderr;
  if (stderr.isNotEmpty) {
    _logger.info(stderr);
    print(stderr);
  }

  return processResult.stdout;
}
