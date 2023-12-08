import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import 'disguise_ua/disguise_ua.dart';

/// [Client] implementation for OgHref packages.
@internal
final class OgHrefClient extends BaseClient {
  /// Default request user agent value.
  static const String DEFAULT_USER_AGENT_STRING = "oghref/2";

  /// Default timeout duration in seconds.
  static const int DEFAULT_TIMEOUT = 10;

  /// Allow redirection if necessary.
  final bool redirect;

  final Client _c = Client();

  /// Current user agent preference of following requests.
  static String userAgent = DEFAULT_USER_AGENT_STRING;

  /// Specify timeout of response after specific seconds.
  static int timeoutAt = DEFAULT_TIMEOUT;

  /// If implemented under HTML, [userAgent] will be replaced by browser
  /// provided one when making request.
  static bool disguise = true;

  OgHrefClient(this.redirect);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = disguise ? disguisedUserAgent : userAgent
      ..followRedirects = redirect;
    return _c.send(request).timeout(Duration(seconds: timeoutAt));
  }
}
