import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser show parse;
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import 'exception/content_type_mismatched.dart';
import 'exception/non_http_url.dart';
import 'model/metainfo.dart';
import 'parser/property_parser.dart';

import 'content_type_verifier.dart';

/// Read [Document] and find all metadata tags to generate corresponded
/// [MetaInfo].
///
/// At the same time, it manages all [MetaPropertyParser] according to
/// [MetaPropertyParser.propertyNamePrefix] and will be refer them
/// for finding matched [MetaPropertyParser].
final class MetaFetch {
  /// Default request user agent value.
  static const String DEFAULT_USER_AGENT_STRING = "oghref 2";

  /// Instance of [MetaFetch].
  static final MetaFetch _instance = MetaFetch._(false);

  /// A collection of [MetaPropertyParser] which identified with their prefix.
  final Set<MetaPropertyParser> _parsers = HashSet(
      equals: (p0, p1) => p0.propertyNamePrefix == p1.propertyNamePrefix,
      hashCode: (p0) => p0.propertyNamePrefix.hashCode);

  final bool _ignoreContentType;

  /// Allow [MetaFetch] fetch redirected [Uri]'s metadata instead of
  /// provided one.
  bool allowRedirect = false;

  String? _primaryPrefix;

  /// Specify which prefix should be resolve at first.
  ///
  /// If it applied as [Null], this feature will be disabled.
  set primaryPrefix(String? prefix) {
    if (prefix != null) {
      try {
        _findCorrespondedParser(prefix);
      } on StateError {
        throw ArgumentError.value(prefix, "primaryPrefix",
            "No registered parser using the given prefix.");
      }
    }

    _primaryPrefix = prefix;
  }

  /// Get which prefix of property will be overriden when parse.
  ///
  /// If it is [Null], the feature will be disabled.
  String? get primaryPrefix => _primaryPrefix;

  MetaFetch._(this._ignoreContentType);

  /// Get a instance of [MetaFetch].
  ///
  /// [MetaFetch] is a singleton object that it allows to uses same [register]
  /// preference whatever been made.
  factory MetaFetch() => _instance;

  /// A dedicated [MetaFetch] which ignore content type condition that allowing
  /// parse to HTML [Document].
  ///
  /// This only available for testing only.
  @visibleForTesting
  static MetaFetch forTest() => MetaFetch._(true);

  /// Define a value of user agent when making request in [fetchFromHttp].
  static String userAgentString = DEFAULT_USER_AGENT_STRING;

  /// Standardize [Function] for finding matched prefix in
  /// [Iterable.singleWhere].
  static bool Function(MetaPropertyParser) _prefixEquals(String prefix) =>
      (mpp) => mpp.propertyNamePrefix == prefix;

  /// Get the corresponded parser from [prefix].
  ///
  /// If no related [prefix] is assigned, [StateError] will
  /// be thrown.
  MetaPropertyParser _findCorrespondedParser(String prefix) {
    return _parsers.singleWhere(_prefixEquals(prefix));
  }

  /// Register [parser] into [MetaFetch].
  ///
  /// It returns `true` if registered sucessfully.
  bool register(MetaPropertyParser parser) {
    return _parsers.add(parser);
  }

  /// Determine the [identifier] is registered or not.
  ///
  /// The [identifier] can be a [String] of prefix or [MetaPropertyParser].
  ///
  /// Return `true` if existed.
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

  /// Remove [MetaPropertyParser] with corresponded [prefix].
  ///
  /// It returns `true` if the given [prefix] has been removed.
  ///
  /// In additions, if [prefix] is the same value of [primaryPrefix],
  /// it will reset to [Null].
  bool deregister(String prefix) {
    if (primaryPrefix == prefix) {
      primaryPrefix = null;
    }

    final int originLength = _parsers.length;
    _parsers.removeWhere(_prefixEquals(prefix));

    return _parsers.length < originLength;
  }

  static Set<String> _offeredPropPrefix(Element? htmlHead) {
    return htmlHead
            ?.querySelectorAll("meta[property][content]")
            .map((e) => e.attributes["property"]!.split(":").first)
            .toSet() ??
        HashSet<String>();
  }

  Iterable<String> _prefixSequence(Document htmlDocument) sync* {
    final offeredPropPrefix = _offeredPropPrefix(htmlDocument.head);

    if (primaryPrefix != null && offeredPropPrefix.contains(primaryPrefix)) {
      yield primaryPrefix!;
      offeredPropPrefix.remove(primaryPrefix);
    }

    for (String remainPrefix in offeredPropPrefix) {
      yield remainPrefix;
    }
  }

  /// Construct [MetaInfo] with given [Document].
  ///
  /// If `<meta>` [Element]'s property prefix [hasBeenRegistered],
  /// it refers to the first matched prefix given from an order
  /// of [Document] and apply all available fields in [MetaInfo].
  /// Otherwise, it will return [MetaInfo] with all empty field
  /// when it cannot be able to find matched prefix.
  ///
  /// **Update in `1.1.1`: This method no longer available
  /// for non testing purpose.**
  @visibleForTesting
  MetaInfo buildMetaInfo(Document htmlDocument) {
    MetaInfo parsedResult = MetaInfo();

    for (String prefix in _prefixSequence(htmlDocument)) {
      try {
        var parser = _findCorrespondedParser(prefix);
        parsedResult = parser.parse(htmlDocument.head!);
        break;
      } on StateError {
        // If the prefix does not supported.
        continue;
      }
    }

    return parsedResult;
  }

  /// Construct all [MetaInfo] with given [Document].
  ///
  /// It returns an unmodifiable [Map] which contains all [register]ed
  /// [MetaPropertyParser]'s results with
  /// [MetaPropertyParser.propertyNamePrefix] as a key of the [Map].
  @visibleForTesting
  Map<String, MetaInfo> buildAllMetaInfo(Document htmlDocument) {
    Map<String, MetaInfo> metaInfoMap = HashMap<String, MetaInfo>();

    for (String prefix in _prefixSequence(htmlDocument)) {
      try {
        var parser = _findCorrespondedParser(prefix);
        metaInfoMap[prefix] = parser.parse(htmlDocument.head!);
      } on StateError {
        // If the prefix does not supported.
        continue;
      }
    }

    return Map.unmodifiable(metaInfoMap);
  }

  Future<Document> _fetchHtmlDocument(Uri url) async {
    const Set<String> eligableType = <String>{"html", "xhtml"};

    if (!RegExp(r"^https?$").hasMatch(url.scheme)) {
      throw NonHttpUrlException(url);
    }

    Request req = Request("GET", url)
      ..headers['user-agent'] = userAgentString
      ..followRedirects = allowRedirect;

    Response resp = await req.send().then(Response.fromStream);

    if (!_ignoreContentType &&
        !resp.isSatisfiedExtension(fileExtensions: eligableType)) {
      throw ContentTypeMismatchedException(
          url, resp.contentType, const {"text/html", "application/xhtml+xml"});
    }

    return html_parser.parse(resp.body);
  }

  /// Retrive [MetaInfo] from HTTP request from [url].
  ///
  /// If [url] is not `HTTP` or `HTTPS`, [NonHttpUrlException]
  /// will be thrown.
  ///
  /// Optionally, [userAgentString] can be modified before making request
  /// that allowing to identify as another user agent rather than
  /// [DEFAULT_USER_AGENT_STRING].
  ///
  /// Once the request got response, it's body content will be [html_parser.parse]
  /// to [Document] directly and perform [buildMetaInfo].
  ///
  /// HTTP response code does not matter in this method that it only
  /// required to retrive HTML content from [url].
  ///
  /// For fetch all metadata protocols in a single [url], please uses
  /// [fetchAllFromHttp] instead.
  Future<MetaInfo> fetchFromHttp(Uri url) {
    return _fetchHtmlDocument(url)
        .then(buildMetaInfo)
        .onError((error, stackTrace) => MetaInfo());
  }

  /// Fetch all [MetaInfo] from various protocols into a single
  /// [Map].
  ///
  /// If [url] is not `HTTP` or `HTTPS`, [NonHttpUrlException]
  /// will be thrown.
  ///
  /// Optionally, [userAgentString] can be modified before making request
  /// that allowing to identify as another user agent rather than
  /// [DEFAULT_USER_AGENT_STRING].
  ///
  /// Once the request got response, it's body content will be [html_parser.parse]
  /// to [Document] directly and perform [buildAllMetaInfo].
  ///
  /// HTTP response code does not matter in this method that it only
  /// required to retrive HTML content from [url].
  Future<Map<String, MetaInfo>> fetchAllFromHttp(Uri url) {
    return _fetchHtmlDocument(url)
        .then(buildAllMetaInfo)
        .onError((error, stackTrace) => const {});
  }
}
