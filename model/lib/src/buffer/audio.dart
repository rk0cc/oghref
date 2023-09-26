import '../model/audio.dart';
import 'immutable_buffer.dart';
import 'media.dart';
import 'url.dart';

final class AudioInfoParser
    with ImmutableBuffer<AudioInfo>, MediaInfoAssigner, UrlInfoAssigner {
  @override
  AudioInfo compile() {
    return AudioInfo(secureUrl: secureUrl, type: type, url: url);
  }

  @override
  void reset() {
    secureUrl = null;
    type = null;
    url = null;
  }
}
