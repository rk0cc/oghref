import '../model/url.dart';

abstract mixin class UrlInfoAssigner implements UrlInfo {
  @override
  Uri? url;

  @override
  Uri? secureUrl;
}
