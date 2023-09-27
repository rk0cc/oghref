import '../model/video.dart';
import 'immutable_buffer.dart';
import 'media.dart';
import 'url.dart';

/// A parser for handling construction of [VideoInfo].
final class VideoInfoParser
    with
        ImmutableBuffer<VideoInfo>,
        MediaInfoAssigner,
        ScalableInfoAssigner,
        UrlInfoAssigner {
  @override
  VideoInfo compile() {
    return VideoInfo(
        height: height,
        secureUrl: secureUrl,
        type: type,
        url: url,
        width: width);
  }

  @override
  void reset() {
    height = null;
    secureUrl = null;
    type = null;
    url = null;
    width = null;
  }
}
