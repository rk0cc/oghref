import 'package:meta/meta.dart';

import 'audio.dart';
import 'image.dart';
import 'video.dart';
import 'url.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

/// Completed structure of rich information link preview metadata.
/// 
/// Although some fields are compulsory (for example, 
/// [basic metadata in Open Graph Protocol](compulsory)), to ensure
/// compatibility on various metadata structures, all fields are
/// defined as optional which denote `null` if absent.
@immutable
final class MetaInfo implements UrlInfo {
  /// Title of website.
  final String? title;

  @override
  final Uri? url;

  @override
  final Uri? secureUrl;

  /// Website's description.
  final String? description;

  /// Name of website.
  final String? siteName;

  /// An unmodifiabled collection of [ImageInfo].
  final List<ImageInfo> images;

  /// An unmodifiabled collection of [VideoInfo].
  final List<VideoInfo> videos;

  /// An unmodifiabled collection of [AudioInfo].
  final List<AudioInfo> audios;

  /// Create rich information link metadata.
  MetaInfo(
      {this.title,
      this.url,
      this.secureUrl,
      this.description,
      this.siteName,
      List<ImageInfo> images = const [],
      List<VideoInfo> videos = const [],
      List<AudioInfo> audios = const []})
      : this.images = List.unmodifiable(images),
        this.videos = List.unmodifiable(videos),
        this.audios = List.unmodifiable(audios);
}
