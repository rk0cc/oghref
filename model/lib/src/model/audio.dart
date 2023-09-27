import 'package:meta/meta.dart';

import 'media.dart';
import 'url.dart';

/// Specify audio metadata in rich informations.
///
/// This object only represent metadata of resources only but
/// not verify support of audio format.
@immutable
final class AudioInfo implements MediaInfo, UrlInfo {
  @override
  final Uri? url;

  @override
  final Uri? secureUrl;

  @override
  final String? type;

  /// Create information of audio metadata.
  AudioInfo({this.url, this.secureUrl, this.type});
}
