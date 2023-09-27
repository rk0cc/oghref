import '../model/url.dart';

/// A mixin for constructing [UrlInfo] implemented parser.
abstract mixin class UrlInfoAssigner implements UrlInfo {
  @override
  Uri? url;

  @override
  Uri? secureUrl;
}
