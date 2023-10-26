import 'dart:collection';

import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';
import 'package:mime_dart/mime_dart.dart';
import 'package:path/path.dart' as p;

/// Determine the content type category from MIME.
@internal
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
@internal
extension ContentTypeVerifier on Response {
  /// Get the `Content-Type` value directly from [headers].
  String? get contentType => headers["content-type"];

  /// Determine the [contentType] is one of the expected [fileExtensions].
  bool isSatisfiedExtension({Set<String> fileExtensions = const {}}) {
    final Set<String> acceptedExtension = {...fileExtensions};
    if (acceptedExtension.isEmpty) {
      acceptedExtension.add("txt");
    }

    String? mimeData = contentType;

    final List<String> extTypes = [];

    if (mimeData != null) {
      extTypes.addAll(
          Mime.getExtensionsFromType(mimeData.split(';').first) ?? const []);
    }

    return acceptedExtension.any((element) => extTypes.contains(element));
  }

  /// Determine this response's [ContentTypeCategory] is the same.
  bool isSatisfiedContentTypeCategory(ContentTypeCategory category) {
    if (contentType != null) {
      return contentType!.split("/").first == category.name;
    }

    return false;
  }
}

/// Perform prediction of content type by given file extension in [Uri.path].
@internal
extension UriFileExtensionVeifier on Uri {
  /// Guess this [category] is matched one of the possible file extensions.
  /// 
  /// If the given [path] does not offered extension, it always return `false`.
  bool isMatchedContentTypeExtension(ContentTypeCategory category) {
    Set<String> mimeFromExt =
        Mime.getTypesFromExtension(p.extension(path))?.toSet() ?? HashSet();

    return mimeFromExt
        .any((element) => element.split("/").first == category.name);
  }
}
