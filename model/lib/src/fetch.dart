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
import 'client.dart';
import 'content_type_verifier.dart';

/// Read [Document] and find all metadata tags to generate corresponded
/// [MetaInfo].
///
/// At the same time, it manages all [MetaPropertyParser] according to
/// [MetaPropertyParser.propertyNamePrefix] and will be refer them
/// for finding matched [MetaPropertyParser].
abstract final class MetaFetch {
  /// Instance of [MetaFetch].
  static MetaFetch? _instance;

  /// Get current [instance] of [MetaFetch].
  ///
  /// It will construct automatically if no instance created before.
  static MetaFetch get instance {
    _instance ??= MetaFetch();

    return _instance!;
  }

  /// Set a new [instance] for retrive [MetaFetch].
  static set instance(MetaFetch newInstance) {
    _instance = newInstance;
  }

  /// A collection of [MetaPropertyParser] which identified with their prefix.
  final Set<MetaPropertyParser> _parsers = HashSet(
      equals: (p0, p1) => p0.propertyNamePrefix == p1.propertyNamePrefix,
      hashCode: (p0) => p0.propertyNamePrefix.hashCode);

  //final OgHrefClient _client = OgHrefClient(true);

  /// Allow [MetaFetch] fetch redirected [Uri]'s metadata instead of
  /// provided one.
  bool allowRedirect = true;

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

  /// Determine does [primaryPrefix] is ready to uses.
  ///
  /// This getter is completely equals with the following
  /// syntax:
  ///
  /// ```dart
  /// bool isPrimaryPrefixEnabled = MetaFetch.instance.primaryPrefix != null;
  /// ```
  bool get isPrimaryPrefixEnabled => _primaryPrefix != null;

  MetaFetch._();

  /// Get a instance of [MetaFetch].
  ///
  /// [MetaFetch] is a singleton object that it allows to uses same [register]
  /// preference whatever been made.
  factory MetaFetch() = _MetaFetchProducer;

  /// A dedicated [MetaFetch] which ignore content type condition that allowing
  /// parse to HTML [Document].
  ///
  /// This only available for testing only.
  @visibleForTesting
  factory MetaFetch.forTest() = _MetaFetchTester;

  /// Define a value of user agent when making request in [fetchFromHttp].
  ///
  /// If [disguiseUserAgent] enabled, any changes will not be applied
  /// until it disabled and uses user defined again.
  static void changeUserAgent(
      [String userAgent = OgHrefClient.DEFAULT_USER_AGENT_STRING]) {
    OgHrefClient.userAgent = userAgent;
  }

  /// Define timeout of response.
  ///
  /// Default value is `10`.
  static void changeTimeout([int seconds = OgHrefClient.DEFAULT_TIMEOUT]) {
    OgHrefClient.timeoutAt = seconds;
  }

  /// Change preference of using user agent given by web browser.
  static set disguiseUserAgent(bool disguise) {
    OgHrefClient.disguise = disguise;
  }

  /// Determine using user agent from web browser instead of [userAgentString].
  ///
  /// This does not applied under native environment and no returned value
  /// changes of [userAgentString].
  static bool get disguiseUserAgent => OgHrefClient.disguise;

  /// Retrive current preference of user agent [String].
  ///
  /// When [disguiseUserAgent] enabled in web platform, it returns web
  /// browser's user agent instead of user defined value.
  static String get userAgentString => OgHrefClient.userAgent;

  /// Retrive current preference of timeout.
  static int get timeout => OgHrefClient.timeoutAt;

  /// Standardize [Function] for finding matched prefix in
  /// [Iterable.singleWhere].
  static bool Function(MetaPropertyParser) _prefixEquals(String prefix) =>
      // ignore: return_of_do_not_store
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

  MetaInfo _buildMetaInfo(Document htmlDocument) {
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

  Map<String, MetaInfo> _buildAllMetaInfo(Document htmlDocument) {
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

  bool _verifyContentType(Response resp);

  Future<Document> _fetchHtmlDocument(Uri url) async {
    if (!RegExp(r"^https?$").hasMatch(url.scheme)) {
      throw NonHttpUrlException(url);
    }

    Client client = OgHrefClient(allowRedirect);

    late Response resp;

    try {
      resp = await client.get(url);
    } finally {
      client.close();
    }

    _verifyContentType(resp);

    return html_parser.parse(resp.body);
  }

  /// Retrive [MetaInfo] from HTTP request from [url].
  ///
  /// If [url] is not `HTTP` or `HTTPS`, [NonHttpUrlException]
  /// will be thrown. Additionally, if [url] located neither
  /// HTML nor XHTML resources, [ContentTypeMismatchedException]
  /// will be thrown.
  ///
  /// Optionally, [userAgentString] can be modified before making request
  /// that allowing to identify as another user agent rather than
  /// default one unless [disguiseUserAgent] set as `true` which
  /// override user agent string from web browser instead.
  ///
  /// Once the request got response, it's body content will be [html_parser.parse]
  /// to [Document] directly and perform build [MetaInfo].
  ///
  /// HTTP response code does not matter in this method that it only
  /// required to retrive HTML content from [url].
  ///
  /// For fetch all metadata protocols in a single [url], please uses
  /// [fetchAllFromHttp] instead.
  Future<MetaInfo> fetchFromHttp(Uri url) {
    return _fetchHtmlDocument(url).then(_buildMetaInfo);
  }

  /// Fetch all [MetaInfo] from various protocols into a single
  /// [Map].
  ///
  /// If [url] is not `HTTP` or `HTTPS`, [NonHttpUrlException]
  /// will be thrown. Additionally, if [url] located neither
  /// HTML nor XHTML resources, [ContentTypeMismatchedException]
  /// will be thrown.
  ///
  /// Optionally, [userAgentString] can be modified before making request
  /// that allowing to identify as another user agent rather than
  /// default one unless [disguiseUserAgent] set as `true` which
  /// override user agent string from web browser instead.
  ///
  /// Once the request got response, it's body content will be [html_parser.parse]
  /// to [Document] directly and build [MetaInfo] for all
  /// supported protocols.
  ///
  /// HTTP response code does not matter in this method that it only
  /// required to retrive HTML content from [url].
  Future<Map<String, MetaInfo>> fetchAllFromHttp(Uri url) {
    return _fetchHtmlDocument(url).then(_buildAllMetaInfo);
  }
}

final class _MetaFetchTester extends MetaFetch {
  _MetaFetchTester() : super._();

  @override
  bool _verifyContentType(Response resp) {
    return true;
  }
}

final class _MetaFetchProducer extends MetaFetch {
  static const Set<String> eligableExtensions = <String>{"html", "xhtml"};
  static const Set<String> supportedContentType = <String>{
    "text/html",
    "application/xhtml+xml"
  };

  _MetaFetchProducer() : super._();

  @override
  bool _verifyContentType(Response resp) {
    if (!resp.isSatisfiedExtension(fileExtensions: eligableExtensions)) {
      throw ContentTypeMismatchedException(
          resp.request!.url, resp.contentType, supportedContentType);
    }

    return true;
  }
}
