import 'dart:collection';

import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';
import 'package:mime_dart/mime_dart.dart';
import 'package:path/path.dart' as p;

@internal
enum ContentTypeCategory { audio, video, image, text, application }

@internal
extension ContentTypeVerifier on Response {
  String? get contentType => headers["content-type"];

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

  bool isSatisfiedContentTypeCategory(ContentTypeCategory category) {
    if (contentType != null) {
      return contentType!.split("/").first == category.name;
    }

    return false;
  }
}

@internal
extension UriFileExtensionVeifier on Uri {
  bool isMatchedContentTypeExtension(ContentTypeCategory category) {
    Set<String> mimeFromExt =
        Mime.getTypesFromExtension(p.extension(path))?.toSet() ?? HashSet();

    return mimeFromExt.any((element) => element.split("/").first == category.name);
  }
}
