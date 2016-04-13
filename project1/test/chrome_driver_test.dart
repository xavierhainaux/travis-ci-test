@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:webdriver/io.dart';

main() {

  test('Start webdriver and take capture in Dartium', () async {
    Process chromeDriver = await _startChromeDriver(4444);

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {
      'binary': Platform.environment['DARTIUM_BIN']
    };

    Uri wdUri = Uri.parse('http://localhost:4444/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri, desired: capabilities);

    await webDriver.get('https://www.google.com');

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Dartium ok ${screenshot.length}');

    await webDriver.close();
    chromeDriver.kill();
  });

  test('Start webdriver and take capture with chrome', () async {
    Process chromeDriver = await _startChromeDriver(4444);

    await _startChromeDriver(4444);

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {
      'binary': Platform.environment['CHROME_BIN']
    };

    Uri wdUri = Uri.parse('http://localhost:4444/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri, desired: capabilities);


    await webDriver.get('https://www.google.com');

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Chrome ok ${screenshot.length}');

    await webDriver.close();
    chromeDriver.kill();
  });
}

Future<Process> _startChromeDriver(int port) async {
  Process browser = await Process
      .start('chromedriver', ['--port=$port', '--url-base=wd/hub']);
  print(browser.stderr);

  await for (String browserOut
      in UTF8.decoder.fuse(const LineSplitter()).bind(browser.stdout)) {
    print('browser $browserOut');
    if (browserOut.contains('Starting ChromeDriver')) {
      break;
    }
  }
  return browser;
}
