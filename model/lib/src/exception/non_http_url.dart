/// Indicate the given [Uri] is not using HTTP(S) protocol.
final class NonHttpUrlException implements Exception {
  /// Non-HTTP(S) [Uri].
  final Uri url;

  /// Create an exception which using invalid protocol [url].
  NonHttpUrlException(this.url);

  @override
  String toString() =>
      "NonHttpUrlException: The given URL is not HTTP(S) - $url";
}
