import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import 'ua.dart' if (dart.library.js_interop) 'ua_web.dart';

@internal
final class OgHrefMediaClient extends BaseClient {
  final Client _c = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = requestUserAgent
      ..followRedirects = false;

    return request.send();
  }

  @override
  void close() {
    _c.close();
  }
}
