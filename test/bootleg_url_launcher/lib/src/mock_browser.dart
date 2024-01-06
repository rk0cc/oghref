import 'dart:math' show Random;

import 'package:faker/faker.dart' show Faker;
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:http/testing.dart';
import 'package:meta/meta.dart';

Duration get _simulatedDelay {
  late Random rand;

  try {
    rand = Random.secure();
  } on UnsupportedError {
    rand = Random();
  }

  return Duration(milliseconds: rand.nextInt(4750) + 250);
}

@internal
final class MockBrowserUAClient extends BaseClient {
  final Client _c;

  MockBrowserUAClient(bool testMode)
      : _c = testMode
            ? MockClient((request) => Future.delayed(_simulatedDelay, () {
                  return Response(
                      request.method.toUpperCase() == "GET"
                          ? r"""
<!DOCTYPE html>
<html>
    <head>
        <title>Sample 1</title>
        <meta charset="utf-8"/>
        <meta property="og:title" content="Sample 1"/>
        <meta property="og:url" content="https://example.com"/>
        <meta property="og:type" content="website"/>
        <meta property="og:image" content="https://media.githubusercontent.com/media/rk0cc/oghref/main/widgets/material/screenshots/oghref_material.png"/>
        <meta property="og:image:width" content="400" />
        <meta property="og:image:height" content="300" />
    </head>
    <body>
        <p>HTML Sample 1</p>
        <script src="alert.js"></script>
    </body>
</html>
"""
                          : "",
                      200,
                      request: request,
                      headers: const {"content-type": "text/plain"});
                }))
            : Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers.putIfAbsent('user-agent', Faker().internet.userAgent)
      ..followRedirects = true;

    return _c.send(request);
  }

  @override
  void close() {
    _c.close();
  }
}
