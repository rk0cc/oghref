import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import 'ua.dart' if (dart.library.html) 'ua_web.dart';

@internal
final class OgHrefMediaClient extends BaseClient {
  final Client _c = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] =
          requestUserAgent ?? "Mozilla/5.0 oghref/2 (Media classification)"
      ..followRedirects = true;

    return request.send();
  }

  @override
  void close() {
    _c.close();
  }
}
