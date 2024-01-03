import 'package:faker/faker.dart' show Faker;
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

@internal
final class MockBrowserUAClient extends BaseClient {
  final Client _c = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers['user-agent'] = Faker().internet.userAgent()
      ..followRedirects = true;

    return _c.send(request).timeout(const Duration(minutes: 1));
  }
}
