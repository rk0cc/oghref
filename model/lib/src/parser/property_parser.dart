import 'dart:collection';

import 'package:html/dom.dart';
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import '../model/metainfo.dart';
import '../model/url.dart';
import '../buffer/metainfo.dart';
import '../content_type_verifier.dart';
import '../fetch.dart' show MetaFetch;

/// A [String] pair [Record] represents `property` and `content` attribute
/// in `<meta>` tag.
typedef PropertyPair = (String name, String content);

/// A parser for constructing [MetaInfo] given [Document]
/// in HTML.
abstract base mixin class MetaPropertyParser {
  /// Create new [MetaInfoParser] for resolving property name
  /// with [propertyNamePrefix].
  const MetaPropertyParser();

  /// Prefix of property's name which identify which rich information
  /// provider is used.
  ///
  /// Reference of values:
  /// |     Providers     |Prefix of property name|    Example   |
  /// |:-----------------:|:---------------------:|:------------:|
  /// |Open Graph Protocol|         `og`          |  `og:title`  |
  /// |   Twitter Card    |      `twitter`        |`twitter:card`|
  String get propertyNamePrefix;

  /// Actual implementation of assigning [MetaInfo] given all `<meta>`
  /// [Element] with corresponded [propertyNamePrefix].
  ///
  /// By resolving [propertyPair] which is unmodifiable
  /// [List] into [assigner] and uses for generating [MetaInfo] in
  /// [parse].
  ///
  /// If necessary, [AudioInfoParser], [ImageInfoParser] and [VideoInfoParser]
  /// can be created under this method for resolving multimedia
  /// metadata content.
  @protected
  void resolveMetaTags(
      MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair);

  /// Resolve rich information metadata from given [htmlHead] which
  /// is `<head>` [Element] in HTML.
  ///
  /// This method should not be [override]. Instead, all data apply
  /// must be done under [resolveMetaTags].
  @nonVirtual
  MetaInfo parse(Element htmlHead) {
    final MetaInfoParser metaParser = MetaInfoParser()..markInitalized();
    final Iterable<PropertyPair> metaTagsProp = htmlHead
        .querySelectorAll(
            r'meta[property^="' + propertyNamePrefix + r':"][content]')
        .map((e) {
      final attr = e.attributes;

      return (attr['property']!, attr['content']!);
    });

    resolveMetaTags(metaParser, UnmodifiableListView(metaTagsProp));

    // Purge any ineligible content type into infos.
    () async {
      Iterable<Uri> getUrlsFromUrlInfo(List<UrlInfo> urlInfos) =>
          urlInfos.where((element) => element.url != null).map((e) => e.url!);

      Stream<(Uri, Response)> buildRespStream(Iterable<Uri> uris) =>
          Stream.fromFutures(uris.map((e) async {
            Request req = Request("HEAD", e)
              ..headers['user-agent'] = MetaFetch.userAgentString;

            Response resp = await req.send().then(Response.fromStream);

            return (e, resp);
          }));

      Iterable<Uri> imgUris = getUrlsFromUrlInfo(metaParser.images),
          vidUris = getUrlsFromUrlInfo(metaParser.videos),
          audUris = getUrlsFromUrlInfo(metaParser.audios);

      Stream<(Uri, Response)> imgResps = buildRespStream(imgUris),
          vidResps = buildRespStream(vidUris),
          audResps = buildRespStream(audUris);

      imgResps.listen((respWithUri) {
        var (url, resp) = respWithUri;
        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.image)) {
          metaParser.images.removeWhere((element) => element.url == url);
        }
      });

      vidResps.listen((respWithUri) {
        var (url, resp) = respWithUri;
        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.video)) {
          metaParser.videos.removeWhere((element) => element.url == url);
        }
      });

      audResps.listen((respWithUri) {
        var (url, resp) = respWithUri;
        if (!resp.isSatisfiedContentTypeCategory(ContentTypeCategory.audio)) {
          metaParser.audios.removeWhere((element) => element.url == url);
        }
      });
    }();

    return metaParser.compile();
  }
}
