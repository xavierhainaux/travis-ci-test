import 'dart:io';

main() async {
  debugInfos();

  var originalDirectory = Directory.current;

  pubGetAll();
  print('build script');

  await _runProcess('project1', 'pub', ['run', 'test']);
  await _runProcess('project1', 'pub', ['run', 'test', '-p', 'dartium']);
  Directory.current = originalDirectory;
  await _runProcess('project1', 'dartanalyzer', ['lib/image_magick.dart']);
  Directory.current = originalDirectory;
}

_runProcess(String directory, String processName, List args) {
  Directory.current = directory;
  return Process.start(processName, args).then((Process process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    return process.exitCode;
  });
}

pubGetAll() {
  var originalDir = Directory.current;
  visitDirectory(Directory.current);
  Directory.current = originalDir;
}

visitDirectory(Directory directory) {
  Directory.current = directory;

  if (hasPubspec) {
    runPubGet();
  } else {
    for (Directory subDirectory
        in directory.listSync().where((f) => f is Directory)) {
      visitDirectory(subDirectory);
    }
  }
}

bool get hasPubspec => new File('pubspec.yaml').existsSync();

runPubGet() {
  print(Directory.current.path);
  ProcessResult result = Process.runSync(pubPath, ['get']);
  if (result.stderr != null && result.stderr.isNotEmpty) {
    print(result.stderr);
  }
  print(result.stdout);
}

String get pubPath {
  if (Platform.operatingSystem == 'windows') {
    return 'pub.bat';
  } else {
    return 'pub';
  }
}

debugInfos() {
  print('home: ' + Platform.environment['HOME']);
  print('current: ${Directory.current.path}');

  for (FileSystemEntity f in new Directory(Platform.environment['HOME'])
      .listSync(recursive: true, followLinks: false)) {
    if (f.path.contains('dartium')) {
      print('${f.path}');
    }
  }
}
