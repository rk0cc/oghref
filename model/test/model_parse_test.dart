import 'package:oghref_model/src/buffer/metainfo.dart';
import 'package:test/test.dart';

import 'package:oghref_model/model.dart';

void main() {
  group('Model parser on', () {
    group('submodels', () {
      test('audio', () {
        AudioInfoParser aip = AudioInfoParser();

        aip
          ..url = Uri.https("example.com", "/example.wav")
          ..type = "audio/wav";

        AudioInfo ai = aip.compile();

        aip
          ..url = Uri.https("example.com", "/example.mp3")
          ..type = "audio/mp3";

        expect(ai.url.toString(), equals("https://example.com/example.wav"));
        expect(ai.type, equals("audio/wav"));
      });
      test('image', () {
        ImageInfoParser iip = ImageInfoParser();

        iip
          ..url = Uri.https("example.com", "/example.wav")
          ..type = "audio/wav";

        ImageInfo ii = iip.compile();

        iip
          ..url = Uri.https("example.com", "/example.mp3")
          ..type = "audio/mp3";

        expect(ii.url.toString(), equals("https://example.com/example.wav"));
        expect(ii.type, equals("audio/wav"));
      });
      test('video', () {
        VideoInfoParser vip = VideoInfoParser();

        vip
          ..url = Uri.https("example.com", "/example.mp4")
          ..type = "video/mp4";

        VideoInfo vi = vip.compile();

        vip
          ..url = Uri.https("example.com", "/example.mov")
          ..type = "video/mov";

        expect(vi.url.toString(), equals("https://example.com/example.mp4"));
        expect(vi.type, equals("video/mp4"));
      });
    });
    test("MetaInfo", () {
      MetaInfoParser parser = MetaInfoParser()
        ..title = "Foo"
        ..siteName = "Dummy parser";

      parser.images.add(ImageInfo(url: Uri.https("foobarbaz.com", "/a.jpg")));

      MetaInfo mi = parser.compile();

      parser.reset();

      expect(mi.images, isNotEmpty);
      expect(mi.title, equals("Foo"));
      expect(mi.siteName, equals("Dummy parser"));
    });
  });
}
