import 'package:test/test.dart';

import 'package:oghref_model/model.dart';
import 'package:oghref_model/buffer_parser.dart';

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
    });
  });
}
