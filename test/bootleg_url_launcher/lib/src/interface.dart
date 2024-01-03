import 'package:http/http.dart' show Client, ClientException;
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mock_browser.dart';

final class BootlegUrlLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launch(String url,
      {required bool useSafariVC,
      required bool useWebView,
      required bool enableJavaScript,
      required bool enableDomStorage,
      required bool universalLinksOnly,
      required Map<String, String> headers,
      String? webOnlyWindowName}) async {
    Client c = MockBrowserUAClient();

    late bool accessible;

    try {
      await c.get(Uri.parse(url), headers: headers);
      accessible = true;
    } on ClientException {
      accessible = false;
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
