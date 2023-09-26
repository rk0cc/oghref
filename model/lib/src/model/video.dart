import 'package:meta/meta.dart';
import 'media.dart';
import 'url.dart';

/// Define metadata information for playing video in preview.
@immutable
final class VideoInfo implements MediaInfo, ScalableInfo, UrlInfo {
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

  /// Create video metadata with provided resources.
  VideoInfo({this.url, this.secureUrl, this.type, this.width, this.height});
}
