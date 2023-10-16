import '../model/url.dart';

/// A mixin for constructing [UrlInfo] implemented parser.
abstract mixin class UrlInfoAssigner {
  /// Define URL address.
  Uri? url;

  /// Define HTTPS URL address.
  Uri? secureUrl;
}
