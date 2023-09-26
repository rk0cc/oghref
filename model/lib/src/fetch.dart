import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser show parse;
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;

import 'model/metainfo.dart';
import 'parser/property_parser.dart';

final class MetaFetch {
  static const String DEFAULT_USER_AGENT_STRING = "oghref 1";
  static final MetaFetch _instance = MetaFetch._();
  final Set<MetaPropertyParser> _parsers = HashSet(
      equals: (p0, p1) => p0.propertyNamePrefix == p1.propertyNamePrefix,
      hashCode: (p0) => p0.propertyNamePrefix.hashCode);

  MetaFetch._();

  factory MetaFetch() => _instance;

  static String userAgentString = DEFAULT_USER_AGENT_STRING;

  static bool Function(MetaPropertyParser) _prefixEquals(String prefix) =>
      (mpp) => mpp.propertyNamePrefix == prefix;

  MetaPropertyParser _findCorrespondedParser(String prefix) {
    return _parsers.singleWhere(_prefixEquals(prefix));
  }

  bool register(MetaPropertyParser parser) {
    return _parsers.add(parser);
  }

  bool hasBeenRegistered(Object identifier) {
    try {
      if (identifier is String) {
        _findCorrespondedParser(identifier);
      } else if (identifier is MetaPropertyParser) {
        _findCorrespondedParser(identifier.propertyNamePrefix);
      }

      return true;
    } on StateError {
      // Non-single case
    }

    return false;
  }

  bool deregister(String prefix) {
    final int originLength = _parsers.length;
    _parsers.removeWhere(_prefixEquals(prefix));

    return _parsers.length < originLength;
  }

  MetaInfo buildMetaInfo(Document htmlDocument) {
    final offeredPropPrefix = htmlDocument.head
        ?.querySelectorAll("meta[property][content]")
        .map((e) => e.attributes["property"]!.split(":").first)
        .toSet();

    MetaInfo parsedResult = MetaInfo();

    if (offeredPropPrefix != null) {
      for (String prefix in offeredPropPrefix) {
        try {
          var parser = _findCorrespondedParser(prefix);
          parsedResult = parser.parse(htmlDocument.head!);
          break;
        } on StateError {
          continue;
        }
      }
    }

    return parsedResult;
  }

  Future<MetaInfo> fetchFromHttp(Uri url) {
    if (!RegExp(r"^https?$").hasMatch(url.scheme)) {
      throw NonHttpUrlException._(url);
    }

    Request req = Request("GET", url)..headers['user-agent'] = userAgentString;
    
    return req.send().then(Response.fromStream).then((resp) {
      String body = resp.body;

      return html_parser.parse(body);
    }).then(buildMetaInfo);
  }
}

final class NonHttpUrlException implements Exception {
  final Uri url;

  NonHttpUrlException._(this.url);

  @override
  String toString() =>
      "NonHttpUrlException: The given URL is not HTTP(S) - $url";
}
