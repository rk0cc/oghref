import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:http/testing.dart';
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
}

@internal
@visibleForTesting
final class MockOgHrefClient extends MockClient implements OgHrefClient {
  MockOgHrefClient() : super(_mockResponse);

  static Future<Response> _mockResponse(Request request) {
    const Map<String, String> mockHeaders = {"content-type": "text/plain"};

    Uri url = request.url;

    if (!RegExp(r"^https?", caseSensitive: false).hasMatch(url.scheme) ||
        !url.isAbsolute) {
      throw ClientException(
          "The request URL must be completed HTTP(S) address, eventhough it made by mock client");
    } else if (url.host != "127.0.0.2") {
      return Future.value(Response("", 400));
    }

    return Future<Response>.delayed(const Duration(milliseconds: 250), () {
      switch (int.parse(url.path.replaceAll(RegExp(r"[^0-9]"), ""))) {
        case 1:
          return Response(r"""
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
""", 200, request: request, headers: mockHeaders);
        case 2:
          return Response(r"""
<!DOCTYPE html>
<html>
    <head>
        <title>Sample 2</title>
        <meta charset="utf-8"/>
        <meta property="og:title" content="Sample 2"/>
        <meta property="og:url" content="https://example.com"/>
        <meta property="og:type" content="website"/>
        <!-- These properties will be ignored when setting before og:image -->
        <meta property="og:image:width" content="400" />
        <meta property="og:image:height" content="300" />
        <!-- End of ignorance -->
        <meta property="og:image" content="https://media.githubusercontent.com/media/rk0cc/oghref/main/widgets/material/screenshots/oghref_material.png"/>
    </head>
    <body>
        <p>HTML Sample 2</p>
        <script src="alert.js"></script>
    </body>
</html>
""", 200, request: request, headers: mockHeaders);
        case 3:
          return Response(r"""
<!DOCTYPE html>
<!-- This file suppose read absolutely noting -->
<html>
    <head>
        <title>Sample 3</title>
        <meta charset="utf-8"/>
        <!-- Uses JS to create meta tags -->
    </head>
    <body>
        <p>HTML Sample 3</p>
        <script src="alert.js"></script>
        <script>
            /*
                These method does not work.
            */
            /**
             * @type {{title:string, url: URL, description: string?, image: URL}}
             */
            var ogObj = {
                title: "Sample 3",
                url: new URL("https://example.com"),
                description: "This sample created by JavaScript",
                image: new URL("https://media.githubusercontent.com/media/rk0cc/oghref/main/widgets/material/screenshots/oghref_material.png")
            };

            for (var ogObjKey in ogObj) {
                var metaElement = document.createElement("meta");
                metaElement.setAttribute("property", `og:${ogObjKey}`);

                var contentVal = ogObj[ogObjKey];
                if (contentVal != null) {
                    metaElement.setAttribute("content", contentVal);
                }

                document.head.appendChild(metaElement);
            }
        </script>
    </body>
</html>
""", 200, request: request, headers: mockHeaders);
        case 4:
          return Response(r"""
<!DOCTYPE html>
<html>
    <head>
        <title>Sample 1</title>
        <meta charset="utf-8"/>
        <meta property="og:title" content="Sample 4"/>
        <meta property="og:url" content="https://example.com"/>
        <meta property="og:type" content="website"/>
        <meta property="og:image" content="https://example.com/sample.raw"/>
        <meta property="og:image:width" content="400" />
        <meta property="og:image:height" content="300" />
    </head>
    <body>
        <p>HTML Sample 4</p>
        <script src="alert.js"></script>
    </body>
</html>
""", 200, request: request, headers: mockHeaders);
        default:
          return Response("Not found", 400,
              request: request, headers: mockHeaders);
      }
    }).onError<Response>((error, stackTrace) {
      return Response("", 500, request: request, headers: mockHeaders);
    });
  }

  @override
  Client get _c => this;

  @override
  bool redirect = false;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = OgHrefClient.userAgent
      ..followRedirects = redirect;

    return super.send(request);
  }
}
