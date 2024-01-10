part of 'client.dart';

const List<String> _sampleContents = [
  r"""<!DOCTYPE html>
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
""",
  r"""<!DOCTYPE html>
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
""",
  r"""<!DOCTYPE html>
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
""",
  r"""<!DOCTYPE html>
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
"""
];

final Uri _sampleMockHost = Uri.https("127.0.0.2");

/// Simulated environment based on [MockClient] that
/// all generated content are specified by
/// tester already.
final class MockOgHrefClient extends BaseClient
    implements MockClient, OgHrefClient {
  @override
  late final Client _c;

  /// Redirect features is always disabled for [MockOgHrefClient].
  @override
  bool get redirect => false;

  /// Define new replicated [Client] for executing under
  /// test environment.
  ///
  /// All expected content in specific links should be stored
  /// into [contentLinker] which is a [Map] with [Uri] key and
  /// [String] value to denotes expected content in [contentType]
  /// when "surfing" URL. If the incoming [Request.url]
  /// can be found in [contentLinker], the returned [Response]
  /// will provided content of the [Uri] in status code `200`.
  /// Otherwise, it returns empty [String] with status code
  /// `404`.
  ///
  /// Default [contentType] uses `text/plain` as returned value
  /// when making [Response]. However, there are only three
  /// eligable values can be used without throwing [ContentTypeMismatchedException]
  /// in [MetaFetch.fetchFromHttp] or [MetaFetch.fetchAllFromHttp] that
  /// they are the most suitable type for using in webpage:
  ///
  /// * `text/plain`
  /// * `text/html`
  /// * `application/xhtml+xml`
  ///
  /// Moreover, every [Uri] mapped in [contentLinker] **MUST BE** used
  /// `HTTP(S)` protocol. If at least one [Uri.scheme] return other than
  /// `HTTP(S)`, it throws [ArgumentError].
  MockOgHrefClient(Map<Uri, String> contentLinker,
      {String contentType = "text/plain"}) {
    if (contentLinker.keys.any((element) => !_isHttpScheme(element))) {
      throw ArgumentError(
          "Content linker's URL must be assigned with HTTP(S) scheme.");
    }

    _c = MockClient((request) {
      final Map<Uri, String> ctxLinker = Map.unmodifiable(contentLinker);

      Uri incomingUrl = request.url;

      if (!_isHttpScheme(incomingUrl)) {
        throw ClientException(
            "The request should be HTTP(S), eventhough is mock client.");
      }

      return Future.delayed(Duration(milliseconds: Random().nextInt(750) + 250),
          () {
        String? bodyCtx = ctxLinker[incomingUrl];

        if (bodyCtx == null) {
          return Response("", 404,
              headers: {"content-type": contentType}, request: request);
        }

        return Response(bodyCtx, 200,
            headers: {"content-type": contentType}, request: request);
      });
    });
  }

  /// Uses [sample files](https://github.com/rk0cc/oghref/tree/main/model/sample) to defined
  /// content of the simulated HTML files with hosted IP address as `127.0.0.2` with `HTTPS`
  /// protocol.
  factory MockOgHrefClient.usesSample() => MockOgHrefClient(<Uri, String>{
        for (int idx = 0; idx < _sampleContents.length; idx++)
          _sampleMockHost.resolve("${idx + 1}.html"): _sampleContents[idx]
      });

  static bool _isHttpScheme(Uri url) {
    return RegExp(r"^https?$", caseSensitive: false).hasMatch(url.scheme);
  }

  @override
  void close() {
    _c.close();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request
      ..headers["user-agent"] = OgHrefClient.userAgent
      ..followRedirects = redirect;
    return _c.send(request).timeout(Duration(seconds: OgHrefClient.timeoutAt));
  }
}
