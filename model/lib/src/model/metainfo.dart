import 'package:meta/meta.dart';

import 'audio.dart';
import 'image.dart';
import 'video.dart';
import 'url.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

enum MetaMergePreference { fillTheBlank, appendMediaOnly }

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

  static MetaInfo merge(MetaInfo primary,
      {List<MetaInfo> fallbacks = const [],
      required MetaMergePreference preference}) {
    final Iterable<MetaInfo> validFallbacks =
        fallbacks.where((element) => !identical(element, primary));

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
        return MetaInfo(
            url: primary.url ?? findFirstNonBlankFallback<Uri>((m) => m.url),
            secureUrl: primary.secureUrl ??
                findFirstNonBlankFallback<Uri>((m) => m.secureUrl),
            description: primary.description ??
                findFirstNonBlankFallback<String>((m) => m.description),
            siteName: primary.siteName ??
                findFirstNonBlankFallback<String>((m) => m.siteName),
            title: primary.title ??
                findFirstNonBlankFallback<String>((m) => m.title),
            images: primary.images,
            videos: primary.videos,
            audios: primary.audios);
      case MetaMergePreference.appendMediaOnly:
        return MetaInfo(
            url: primary.url,
            secureUrl: primary.secureUrl,
            description: primary.description,
            siteName: primary.siteName,
            title: primary.title,
            images: <ImageInfo>[
              ...primary.images,
              ...validFallbacks
                  .map((e) => e.images)
                  .expand((element) => element)
            ],
            videos: <VideoInfo>[
              ...primary.videos,
              ...validFallbacks
                  .map((e) => e.videos)
                  .expand((element) => element)
            ],
            audios: <AudioInfo>[
              ...primary.audios,
              ...validFallbacks
                  .map((e) => e.audios)
                  .expand((element) => element)
            ]);
    }
  }
}
