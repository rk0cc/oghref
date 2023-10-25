import 'dart:async';

import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import '../fetch.dart' show MetaFetch;
import '../content_type_verifier.dart';
import 'audio.dart';
import 'image.dart';
import 'video.dart';
import 'url.dart';

export 'audio.dart';
export 'image.dart';
export 'video.dart';

/// A preference for operationg [MetaInfo.merge].
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

  MetaInfo._(this.title, this.url, this.secureUrl, this.description,
      this.siteName, this.audios, this.images, this.videos);

  /// Create rich information link metadata.
  factory MetaInfo(
      {String? title,
      Uri? url,
      Uri? secureUrl,
      String? description,
      String? siteName,
      List<AudioInfo> audios = const [],
      List<ImageInfo> images = const [],
      List<VideoInfo> videos = const []}) {
    final List<AudioInfo> filteredAudios = List.of(audios);
    final List<ImageInfo> filteredImages = List.of(images);
    final List<VideoInfo> filteredVideos = List.of(videos);

    // Purge any ineligible content type into infos.
    () async {
      _MetaInfoClient c = _MetaInfoClient();

      Iterable<Uri> getUrlsFromUrlInfo(List<UrlInfo> urlInfos) =>
          urlInfos.where((element) => element.url != null).map((e) => e.url!);

      Stream<(Uri, Response)> buildRespStream(Iterable<Uri> uris) =>
          Stream.fromFutures(uris.map((e) async {
            Response resp = await c.head(e);

            return (e, resp);
          }));

      Iterable<Uri> imgUris = getUrlsFromUrlInfo(images),
          vidUris = getUrlsFromUrlInfo(videos),
          audUris = getUrlsFromUrlInfo(audios);

      Stream<(Uri, Response)> imgResps = buildRespStream(imgUris),
          vidResps = buildRespStream(vidUris),
          audResps = buildRespStream(audUris);

      await for((Uri, Response) ur in imgResps) {
        var (url, resp) = ur;

        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.image)) {
          filteredImages.removeWhere((element) => element.url == url);
        }
      }

      await for((Uri, Response) ur in vidResps) {
        var (url, resp) = ur;

        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.video)) {
          filteredVideos.removeWhere((element) => element.url == url);
        }
      }

      await for((Uri, Response) ur in audResps) {
        var (url, resp) = ur;

        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.audio)) {
          filteredAudios.removeWhere((element) => element.url == url);
        }
      }
    }();

    return MetaInfo._(
        title,
        url,
        secureUrl,
        description,
        siteName,
        List.unmodifiable(filteredAudios),
        List.unmodifiable(filteredImages),
        List.unmodifiable(filteredVideos));
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

final class _MetaInfoClient extends BaseClient {
  final Client _nested = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers["user-agent"] = MetaFetch.userAgentString;
    return _nested.send(request);
  }
}