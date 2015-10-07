library asset_loader.src.backend.tool.image_magick;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as Path;

final Logger _logger = new Logger('image_magick');

//TODO(xha): essayer de comprendre pourquoi sur mac il ne regarde pas dans le $PATH
final String _CONVERT_EXECUTABLE =
    Platform.isMacOS ? '/opt/local/bin/convert' : 'convert';
final String _IDENTIFY_EXECUTABLE =
    Platform.isMacOS ? '/opt/local/bin/identify' : 'identify';

ProcessResult _execute(String process, List args) {
  // Sur MacOS, on doit mettre runInShell pour que ça marche (raison?)
  ProcessResult processResult =
      Process.runSync(process, args, runInShell: true);
  String stderr = processResult.stderr;
  if (stderr.isNotEmpty) {
    _logger.warning(stderr);
  }
  String stdout = processResult.stdout;
  if (stdout.isNotEmpty) {
    _logger.fine(stdout);
  }

  return processResult;
}

convert(String input, String output, [List args]) {
  List mergedArgs = [];
  mergedArgs.add(input);
  if (args != null) {
    mergedArgs.addAll(args);
  }
  mergedArgs.add(output);

  _execute(_CONVERT_EXECUTABLE, mergedArgs);
}

const String _INPUT_FILE_TOKEN = '@file';
const String _INPUT_DIRECTORY_TOKEN = '@directory';

resize(String input, String output,
    {num width,
    num height,
    ResizeUnit unit: ResizeUnit.pixel,
    String format}) {
  String sizeToString(num size, ResizeUnit unit) {
    return '${size.toInt()}${unit == ResizeUnit.percent ? '%': ''}';
  }

  String widthStr = width != null ? sizeToString(width, unit) : null;
  String heightStr = height != null ? sizeToString(height, unit) : null;

  String cmd = _getResizeCommand(widthStr, heightStr);
  cmd = _escapeCmd(cmd);
  List args;
  if (cmd != null) {
    args = splitsArgs(cmd);
  }

  //TODO(xha): rajouter la couleur du background si spécifié
  // <cmd> -background $backgroundColor -flatten

  //TODO(xha): proposer un format RGBA4444 et RGBA5555
  // qui ferait: -depth 4
  if (format != null) {
    output = '${format.toUpperCase()}:$output';
  }

  convert(input, output, args);
}

final RegExp _argSplitter = new RegExp(r'''([^"']\S*|".+?"|'.+?')\s*''');
List<String> splitsArgs(String args) {
  return _argSplitter
  .allMatches(args)
  .map((Match m) => m.group(1).replaceAll("'", "").replaceAll('"', ''))
  .toList();
}


String _getResizeCommand(String width, String height) {
  if (width != null && height == null) {
    return '-resize $width';
  } else if (width == null && height != null) {
    return '-resize x$height';
  } else if (width != null && height != null) {
    return '-resize ${width}x${height}';
  }
  return null;
}

String _escapeCmd(String cmd) {
  if (Platform.isMacOS) {
    return cmd.replaceAll('<', r'\<').replaceAll('>', r'\>');
  } else {
    return cmd
        .replaceAll('^', '^^')
        .replaceAll('<', '^<')
        .replaceAll('>', '^>');
  }
}


enum ResizeUnit { pixel, percent }

ImageInfo identify(String file) {
  String path = file;
  if (!Path.isAbsolute(file)) {
    path = Path.absolute(file);
  }
  ProcessResult processResult = _execute(_IDENTIFY_EXECUTABLE, [path]);

  String stdout = processResult.stdout;
  String stderr = processResult.stderr;
  print(stderr);
  List frames = stdout.split('\n');
  if (frames.length > 0) {
    // Permet d'éviter les problèmes avec les chemins avec des espaces
    String firstFrameStr = frames[0].replaceAll(file, '');
    List firstFrame = firstFrameStr.split(' ');
    String format = firstFrame[1].toLowerCase();
    List size = firstFrame[2].split('x');
    num width = int.parse(size[0]);
    num height = int.parse(size[1]);

    return new ImageInfo(format, width, height);
  }
  throw "[identify] n'a pas réussi à identifier l'image";
}

class ImageInfo {
  final String format;
  final int width, height;

  ImageInfo(this.format, this.width, this.height);
}
