import 'package:meta/meta.dart';

import 'audio.dart';
import 'image.dart';
import 'video.dart';
import 'url.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

/// A preference for operationg [MetaInfo.merge].
enum MetaMergePreference {
  /// Fill null property in [MetaInfo] as much as possible.
  fillTheBlank,

  /// Merge two [MetaInfo]s media resources into a single object.
  appendMediaOnly
}

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

  MetaInfo._(this.title, this.url, this.secureUrl, this.description,
      this.siteName, this.audios, this.images, this.videos);

  /// Create rich information link metadata.
  ///
  /// If [audios], [videos] and [images] contains invalid content type
  /// in [UrlInfo.url], the returned result will not be included.
  factory MetaInfo(
      {String? title,
      Uri? url,
      Uri? secureUrl,
      String? description,
      String? siteName,
      List<AudioInfo> audios = const [],
      List<ImageInfo> images = const [],
      List<VideoInfo> videos = const []}) {
    return MetaInfo._(
        title,
        url,
        secureUrl,
        description,
        siteName,
        List.unmodifiable(audios),
        List.unmodifiable(images),
        List.unmodifiable(videos));
  }

  /// Merge [primary] metadata with [fallbacks] with difference [preference]
  /// applied.
  ///
  /// Please see [MetaMergePreference] for merging options.
  static MetaInfo merge(MetaInfo primary, List<MetaInfo> fallbacks,
      {required MetaMergePreference preference}) {
    final Iterable<MetaInfo> validFallbacks =
        fallbacks.where((element) => !identical(element, primary)).toSet();

    if (validFallbacks.isEmpty) {
      throw ArgumentError(
          "Empty fallbacks or fill with primary MetaInfo itself into fallbacks are forbidden.");
    }

    T? findFirstNonBlankFallback<T extends Object>(
        T? Function(MetaInfo m) filter) {
      Iterable<T> selectedFields = validFallbacks
          .map(filter)
          .where((element) => element != null)
          .cast<T>();

      return selectedFields.isEmpty ? null : selectedFields.first;
    }

    switch (preference) {
      case MetaMergePreference.fillTheBlank:
        return MetaInfo._(
            primary.title ?? findFirstNonBlankFallback<String>((m) => m.title),
            primary.url ?? findFirstNonBlankFallback<Uri>((m) => m.url),
            primary.secureUrl ??
                findFirstNonBlankFallback<Uri>((m) => m.secureUrl),
            primary.description ??
                findFirstNonBlankFallback<String>((m) => m.description),
            primary.siteName ??
                findFirstNonBlankFallback<String>((m) => m.siteName),
            primary.audios,
            primary.images,
            primary.videos);
      case MetaMergePreference.appendMediaOnly:
        return MetaInfo._(
            primary.title,
            primary.url,
            primary.secureUrl,
            primary.description,
            primary.siteName,
            List.unmodifiable(<AudioInfo>[
              ...primary.audios,
              ...fallbacks.map((e) => e.audios).expand((element) => element)
            ]),
            List.unmodifiable(<ImageInfo>[
              ...primary.images,
              ...fallbacks.map((e) => e.images).expand((element) => element)
            ]),
            List.unmodifiable(<VideoInfo>[
              ...primary.videos,
              ...fallbacks.map((e) => e.videos).expand((element) => element)
            ]));
    }
  }
}
