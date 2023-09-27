import '../model/image.dart';
import 'immutable_buffer.dart';
import 'media.dart';
import 'url.dart';

/// A parser for constructin [ImageInfo].
final class ImageInfoParser
    with
        ImmutableBuffer<ImageInfo>,
        MediaInfoAssigner,
        ScalableInfoAssigner,
        UrlInfoAssigner {
  String? alt;

  @override
  ImageInfo compile() {
    return ImageInfo(
        alt: alt,
        height: height,
        secureUrl: secureUrl,
        type: type,
        url: url,
        width: width);
  }

  @override
  void reset() {
    url = null;
    secureUrl = null;
    type = null;
    width = null;
    height = null;
    alt = null;
  }
}
