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

const String _PLAIN_TEXT_MIME = "text/plain";

final Uri _sampleMockHost = Uri.https("127.0.0.2");

/// An entity for linking incoming [Uri] will response
/// ideal content in [MockOgHrefClient].
@immutable
final class MockOgHrefClientContent {
  /// Response content when making response in [MockOgHrefClient].
  final String content;

  /// Specify incoming [content] data type.
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
  final String contentType;

  /// Define simulated response from linked [Uri].
  const MockOgHrefClientContent(
      {required this.content, this.contentType = "text/plain"});

  @override
  int get hashCode => 31 * content.hashCode + 17 * contentType.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is MockOgHrefClientContent) {
      return content == other.content && contentType == other.contentType;
    }

    return false;
  }
}

/// Simulated environment based on [MockClient] that
/// all generated content are specified by
/// tester already.
///
/// Setting applied from [MetaFetch.changeTimeout], [MetaFetch.changeUserAgent]
/// and [MetaFetch.disguiseUserAgent] will also affected in
/// [MockOgHrefClient], but mostly do not alter [Response.body].
final class MockOgHrefClient extends BaseClient
    implements MockClient, OgHrefClient {
  @override
  late final Client _c;

  /// Redirect features is always disabled for [MockOgHrefClient].
  @override
  final bool redirect = false;

  static Duration _generateResponseDelay() {
    late Random rand;

    try {
      rand = Random.secure();
    } on UnsupportedError {
      rand = Random();
    }

    return Duration(milliseconds: rand.nextInt(750) + 250);
  }

  /// Define new replicated [Client] for executing under
  /// test environment.
  ///
  /// All expected content in specific links should be stored
  /// into [contentLinker] which is a [Map] with [Uri] key and
  /// [MockOgHrefClientContent] as a value which denotes
  /// expected content and content type when "surfing" URL.
  /// If the incoming [Request.url] can be found in [contentLinker],
  /// the returned [Response] will provided content of the [Uri] in
  /// status code `200` and `404` when no [Uri] mapped.
  /// However, it returns HTTP status `400` if the incoming
  /// [Request.method] is neither `GET` nor `HEAD`.
  ///
  /// Moreover, every [Uri] mapped in [contentLinker] **MUST BE** used
  /// `HTTP(S)` protocol. If at least one [Uri.scheme] return other than
  /// `HTTP(S)`, it throws [ArgumentError].
  ///
  /// #### See also
  ///
  /// * [MockOgHrefClient.quick] : Quick builder version of [MockOgHrefClient]
  ///   that [Uri]s are mapping with [String] content with unified
  ///   content type.
  MockOgHrefClient.advance(Map<Uri, MockOgHrefClientContent> contentLinker,
      {String errorContentType = _PLAIN_TEXT_MIME}) {
    if (contentLinker.keys.any((element) => !_isHttpScheme(element))) {
      throw ArgumentError(
          "Content linker's URL must be assigned with HTTP(S) scheme.");
    }

    _c = MockClient((request) {
      final Map<Uri, MockOgHrefClientContent> ctxLinker =
          Map.unmodifiable(contentLinker);

      Uri incomingUrl = request.url;

      if (!_isHttpScheme(incomingUrl)) {
        throw ClientException(
            "The request should be HTTP(S), eventhough is mock client.");
      }

      return Future.delayed(_generateResponseDelay(), () {
        final Map<String, String> errorHeader = {
          "content-type": errorContentType
        };

        if (!{"GET", "HEAD"}
            .any((element) => element == request.method.toUpperCase())) {
          return Response("", 400, request: request, headers: errorHeader);
        }

        MockOgHrefClientContent? bodyCtx = ctxLinker[incomingUrl];

        if (bodyCtx == null) {
          return Response("", 404, headers: errorHeader, request: request);
        }

        return Response(request.method == "GET" ? bodyCtx.content : "", 200,
            headers: {"content-type": bodyCtx.contentType}, request: request);
      });
    });
  }

  /// Simplified parameters for constructing [MockOgHrefClient] that
  /// it only maps [Uri]s with content [String] under the same
  /// [contentType] which uses `text/plain` as default.
  ///
  /// For setting [contentLinker] without identical [contentType],
  /// please uses [MockOgHrefClient.advance] instead.
  factory MockOgHrefClient(Map<Uri, String> contentLinker,
          {String contentType = _PLAIN_TEXT_MIME}) =>
      MockOgHrefClient.advance({
        for (var MapEntry(key: url, value: body) in contentLinker.entries)
          url: MockOgHrefClientContent(content: body, contentType: contentType)
      });

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
