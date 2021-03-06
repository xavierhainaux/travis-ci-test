@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:webdriver/io.dart';
import 'package:which/which.dart';
import 'package:path/path.dart' as p;

main() {
  test('Start webdriver and take capture with firefox', () async {
    Process selenium = await _startSelenium(4444);

    Map capabilities = Capabilities.firefox;
    Uri wdUri = Uri.parse('http://localhost:4444/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri, desired: capabilities);

    await webDriver.get('https://www.google.com');

    String ua =
        await webDriver.execute("return window.navigator.userAgent;", []);

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Firefox ok ${screenshot.length} $ua');

    await webDriver.close();
    selenium.kill();
  });

  test('Start webdriver and take capture with Chrome', () async {
    Process chromeDriver = await _startChromeDriver(4448);

    print('Chromium: ${Process.runSync('chromium-browser', ['--version']).stdout}');

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {
      'binary': whichSync('chromium-browser'),
      'args': ['no-sandbox']
    };

    Uri wdUri = Uri.parse('http://localhost:4448/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri, desired: capabilities);

    await webDriver.get('https://www.google.com');

    String ua =
        await webDriver.execute("return window.navigator.userAgent;", []);

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Chrome ok ${screenshot.length} $ua');

    await webDriver.close();
    chromeDriver.kill();
  });

  test('Start webdriver and take capture in Dartium', () async {
    Process chromeDriver = await _startChromeDriver(4446);

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {
      'binary': Platform.environment['DARTIUM_BIN']
    };

    Uri wdUri = Uri.parse('http://localhost:4446/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri, desired: capabilities);

    await webDriver.get('https://www.google.com');

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Dartium ok ${screenshot.length}');

    await webDriver.close();
    chromeDriver.kill();
  });
}

Future<Process> _startChromeDriver(int port) async {
  Process browser = await Process
      .start('chromedriver', ['--port=$port', '--url-base=wd/hub']);

  await for (String browserOut
      in UTF8.decoder.fuse(const LineSplitter()).bind(browser.stdout)) {
    print('browser $browserOut');
    if (browserOut.contains('Starting ChromeDriver')) {
      break;
    }
  }
  await new Future.delayed(const Duration(milliseconds: 1000));
  return browser;
}

Future<Process> _startSelenium(int port) async {
  Process browser =
      await Process.start('java', ['-jar', p.join(Platform.environment['HOME'], 'selenium.jar'), '-port=$port']);

  print('Selenium started');
  _logError(browser);

  await for (String browserOut
      in UTF8.decoder.fuse(const LineSplitter()).bind(browser.stdout)) {
    print('browser $browserOut');
    if (browserOut.contains('Started')) {
      break;
    }
  }
  await new Future.delayed(const Duration(milliseconds: 3000));
  return browser;
}

_logError(Process process) async {
  await for (String browserOut
      in UTF8.decoder.fuse(const LineSplitter()).bind(process.stderr)) {
    print('Error: $browserOut');
  }
}
