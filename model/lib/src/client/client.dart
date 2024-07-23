import 'dart:math' show Random;

import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:http/testing.dart';
import 'package:meta/meta.dart';

import '../disguise_ua/disguise_ua.dart';
import '../exception/content_type_mismatched.dart';
import '../fetch/fetch.dart' show MetaFetch;

import 'client_provider_normal.dart'
  if (dart.library.js_interop) 'client_provider_web.dart';

part 'mock_client.dart';

/// [Client] implementation for OgHref packages.
@internal
final class OgHrefClient extends BaseClient {
  /// Default request user agent value.
  static const String DEFAULT_USER_AGENT_STRING = "oghref/2";

  /// Default timeout duration in seconds.
  static const int DEFAULT_TIMEOUT = 10;

  /// Allow redirection if necessary.
  final bool redirect;

  final Client _c = initializeClient();

  /// Current user agent preference of following requests.
  static String _userAgent = DEFAULT_USER_AGENT_STRING;

  /// Specify new value of user agent if offered.
  static set userAgent(String value) {
    _userAgent = value;
  }

  /// Return current user agent string.
  ///
  /// If [disguise] enabled, it returns [disguisedUserAgent] instead of
  /// user defined.
  static String get userAgent {
    if (disguise) {
      try {
        return disguisedUserAgent;
      } on UnsupportedError {
        // Mostly triggered if running in VM.
      }
    }

    return _userAgent;
  }

  /// Specify timeout of response after specific seconds.
  static int timeoutAt = DEFAULT_TIMEOUT;

  /// If implemented under HTML, [userAgent] will be replaced by browser
  /// provided one when making request.
  static bool disguise = true;

  OgHrefClient(this.redirect);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = userAgent
      ..followRedirects = redirect;
    return _c.send(request).timeout(Duration(seconds: timeoutAt));
  }

  @override
  void close() {
    _c.close();
  }
}
