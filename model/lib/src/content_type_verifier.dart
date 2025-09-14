import 'dart:collection';

import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';
import 'package:mime_dart/mime_dart.dart';
import 'package:path/path.dart' as p;

import 'fetch/fetch.dart';
import 'model/url.dart';

/// Determine the content type category from MIME.
enum ContentTypeCategory {
  /// Audio files
  audio,

  /// Video files
  video,

  /// Image files
  image,

  /// Text files
  text,

  /// Files uses for applications
  application
}

/// Perform verification from retriving `Content-Type` in [Response.headers].
extension ContentTypeVerifier on Response {
  /// Get the `Content-Type` value directly from [headers].
  String? get contentType => headers["content-type"];

  ContentTypeCategory get contentTypeCategory {
    String? mimeCat = contentType?.split("/").first;

    if (mimeCat == null) {
      return ContentTypeCategory.text;
    }

    return ContentTypeCategory.values.singleWhere(
        (element) => element.name == mimeCat,
        orElse: () => ContentTypeCategory.text);
  }

  /// Determine the [contentType] is one of the expected [fileExtensions]
  /// or found from [mimeOverride].
  bool isSatisfiedExtension(
      {Set<String> fileExtensions = const {},
      Set<String> mimeOverride = const {}}) {
    final Set<String> acceptedExtension = {...fileExtensions};
    if (acceptedExtension.isEmpty) {
      acceptedExtension.add("txt");
    }

    String? mimeData = contentType;

    final List<String> extTypes = [...mimeOverride];

    if (mimeData != null) {
      extTypes.addAll(
          Mime.getExtensionsFromType(mimeData.split(';').first) ?? const []);
    }

    return acceptedExtension.any((element) => extTypes.contains(element));
  }

  /// Determine this response's [ContentTypeCategory] is the same.
  bool isSatisfiedContentTypeCategory(ContentTypeCategory category) {
    if (contentType != null) {
      return category == contentTypeCategory;
    }

    return false;
  }
}

/// Retrive the determined given content types from [UrlInfo].
@immutable
final class UrlInfoContentTypeResult {
  /// Source of [UrlInfo].
  final UrlInfo urlInfo;

  /// Determined content type from [UrlInfo.url].
  final ContentTypeCategory httpContentType;

  /// Determined content type from [UrlInfo.secureUrl] if
  /// provided.
  final ContentTypeCategory? httpsContentType;

  UrlInfoContentTypeResult._(
      this.urlInfo, this.httpContentType, this.httpsContentType);

  /// Check does [httpContentType] and [httpsContentType] are equals.
  ///
  /// If [httpsContentType] is not provided, it will return `null` instead
  /// of making decision.
  bool? isEqualsCategory() {
    if (httpsContentType == null) {
      return null;
    }

    return httpContentType == httpsContentType;
  }
}

/// Extended features from [Uri] to determine file extension.
extension _UriFileExtensionInfo on Uri {
  /// Get all possible [ContentTypeCategory] based on
  /// returned MIME values from retriving [path] with [p.extension].
  Set<ContentTypeCategory> get extensionContentType {
    String ext = p.extension(path);

    if (ext.isEmpty) {
      return const {};
    }

    List<String> ctxType =
        Mime.getTypesFromExtension(ext.substring(1)) ?? const [];

    Set<ContentTypeCategory> ctxSet = LinkedHashSet(
        equals: (p0, p1) => p0.index == p1.index,
        hashCode: (p0) => p0.index * 41);

    for (String cT in ctxType) {
      String ctcStr = cT.split("/").first;

      ContentTypeCategory? ctc = ContentTypeCategory.values
          .where((element) => element.name == ctcStr)
          .singleOrNull;

      if (ctc != null) {
        ctxSet.add(ctc);
      }
    }

    return ctxSet;
  }
}

/// Resolve an iteration of [UrlInfo] and yields [UrlInfoContentTypeResult]
/// with resolved content type.
extension IteratedUrlInfoContentTypeResolver on Iterable<UrlInfo> {
  /// Resolve content type from [UrlInfo] and export result.
  ///
  /// The condition of returned [ContentTypeCategory] will be depended on
  /// given extendion from [Uri.path] first. If not offered, it will
  /// try to find `Content-Type` in HTTP response header by making HTTP HEAD request.
  ///
  /// This features will not be availabled during test and [UnsupportedError]
  /// will be thrown if attempted.
  Stream<UrlInfoContentTypeResult> determineContentTypes() async* {
    Client c = MetaFetch.instance.createClient(false);

    try {
      for (var ui in this) {
        ContentTypeCategory httpCT;
        Set<ContentTypeCategory> httpExtCt = ui.url!.extensionContentType;

        if (httpExtCt.isNotEmpty) {
          httpCT = httpExtCt.first;
        } else {
          httpCT =
              await c.head(ui.url!).then((value) => value.contentTypeCategory);
        }

        ContentTypeCategory? httpsCT;
        if (ui.secureUrl != null) {
          Set<ContentTypeCategory> httpsExtCt =
              ui.secureUrl!.extensionContentType;
          if (httpsExtCt.isNotEmpty) {
            httpsCT = httpsExtCt.first;
          } else {
            httpsCT = await c
                .head(ui.secureUrl!)
                .then((value) => value.contentTypeCategory);
          }
        }

        yield UrlInfoContentTypeResult._(ui, httpCT, httpsCT);
      }
    } finally {
      c.close();
    }
  }
}

/// Resolve a single [UrlInfo] into [UrlInfoContentTypeResult].
extension UrlInfoContentTypeResolver on UrlInfo {
  /// Resolve content type of this [UrlInfo].
  ///
  /// See [IteratedUrlInfoContentTypeResolver.determineContentTypes] for
  /// more details on operations.
  Future<UrlInfoContentTypeResult> determineContentTypes() =>
      [this].determineContentTypes().first;
}
