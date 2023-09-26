import 'package:meta/meta.dart';
import 'url.dart';
import 'media.dart';

/// Display thumbnail of website with given image.
/// 
/// This object does not verify the format of image is supported or not.
@immutable
final class ImageInfo implements MediaInfo, ScalableInfo, UrlInfo {
  @override
  final Uri? url;

  @override
  final Uri? secureUrl;

  @override
  final String? type;

  @override
  final double? width;

  @override
  final double? height;

  /// An optional [String] describe an image for accessibility.
  final String? alt;

  /// Create image metadata information.
  ImageInfo(
      {this.url, this.secureUrl, this.type, this.width, this.height, this.alt});
}
