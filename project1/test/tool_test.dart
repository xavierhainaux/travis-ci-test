
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
}