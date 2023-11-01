import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

/// [Client] implementation for OgHref packages.
@internal
final class OgHrefClient extends BaseClient {
  /// Default request user agent value.
  static const String DEFAULT_USER_AGENT_STRING = "oghref 2";

  /// Allow redirection if necessary.
  final bool redirect;

  final Client _c = Client();

  /// Current user agent preference of following requests.
  static String userAgent = DEFAULT_USER_AGENT_STRING;

  OgHrefClient(this.redirect);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = userAgent
      ..followRedirects = redirect;
    return _c.send(request);
  }
}
