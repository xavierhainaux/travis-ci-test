@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:webdriver/io.dart';
import 'package:which/which.dart';

main() {
  test('Start webdriver and take capture with chrome', () async {
    print('chrome ${whichSync('chrome', orElse: () => 'not found')}');
    print('dartium ${whichSync('dartium', orElse: () => 'not found')}');
    print('chromium ${whichSync('chromium', orElse: () => 'not found')}');
    print('chromium-browser ${whichSync('chromium-browser', orElse: () => 'not found')}');
    print('google-chrome ${whichSync('google-chrome', orElse: () => 'not found')}');

    //Process chromeDriver = await _startChromeDriver(4446);

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {'binary': whichSync('chromium-browser')};

    Uri wdUri = Uri.parse('http://localhost:4444/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri/*, desired: capabilities*/);

    await webDriver.get('https://www.google.com');

    String ua =
        await webDriver.execute("return window.navigator.userAgent;", []);

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Selenium ok ${screenshot.length} $ua');

    await webDriver.close();
    //chromeDriver.kill();
  });

  test('Start webdriver and take capture in Dartium', () async {
    Process chromeDriver = await _startChromeDriver(4446);

    Map capabilities = Capabilities.chrome;
    capabilities['chromeOptions'] = {
      'binary': Platform.environment['DARTIUM_BIN']
    };

    Uri wdUri = Uri.parse('http://localhost:4446/wd/hub/');
    WebDriver webDriver = await createDriver(uri: wdUri/*, desired: capabilities*/);

    await webDriver.get('https://www.google.com');

    List screenshot = await webDriver.captureScreenshot().toList();
    print('Dartium ok ${screenshot.length}');

    await webDriver.close();
    //chromeDriver.kill();
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
