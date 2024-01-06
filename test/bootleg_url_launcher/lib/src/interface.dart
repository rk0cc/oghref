import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Client, ClientException;
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mock_browser.dart';

/// Simulating open [url] without calling browser and make `GET`
/// request to [Client] directly.
///
/// This package only can be used for testing only. And adding
/// `url_launcher_platform_interface` dependency is required
/// for overriding instance.
final class BootlegUrlLauncher extends UrlLauncherPlatform {
  final bool testMode;

  BootlegUrlLauncher({this.testMode = false});

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async {
    Client c = MockBrowserUAClient(testMode);

    bool accessible = false;

    try {
      await c.head(Uri.parse(url));
      accessible = true;
    } catch (e) {
      // No further action
    } finally {
      c.close();
    }

    return accessible;
  }

  /// Passes [url] to [Client] for making `GET` request as
  /// simulation of opening [url] in system's browser.
  ///
  /// The condition of
  @override
  Future<bool> launch(String url,
      {required bool useSafariVC,
      required bool useWebView,
      required bool enableJavaScript,
      required bool enableDomStorage,
      required bool universalLinksOnly,
      required Map<String, String> headers,
      String? webOnlyWindowName}) async {
    Client c = MockBrowserUAClient(testMode);

    bool accessible = false;

    try {
      await c.get(Uri.parse(url), headers: headers);
      accessible = true;
    } on ClientException catch (ce) {
      StringBuffer buf = StringBuffer();
      buf
        ..writeln("Client cannot make request with message:")
        ..writeln(ce.message)
        ..writeln()
        ..write("With URL: ");

      Uri? url = ce.uri;

      if (url != null) {
        buf.writeln(Uri.decodeFull("$url"));
      } else {
        buf.writeln("(No URL provided)");
      }

      debugPrint(ce.message, wrapWidth: 80);
    } finally {
      c.close();
    }

    return accessible;
  }

  @override
  Future<void> closeWebView() {
    return Future.delayed(const Duration(microseconds: 10));
  }
}
