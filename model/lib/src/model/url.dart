/// Define metadata information with [url] link.
abstract interface class UrlInfo {
  /// Link to resources.
  /// 
  /// It should be used `HTTP` or `HTTPS` protocol.
  Uri? get url;

  /// Link to resources using `HTTPS`.
  Uri? get secureUrl;
}
