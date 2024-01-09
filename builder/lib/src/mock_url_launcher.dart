import 'package:http/testing.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Replication of [UrlLauncherPlatform] which replaces all interaction
/// with calling browser features to [MockClient].
final class MockUrlLauncherPlatform extends UrlLauncherPlatform {
  final MockClient Function() _constructor;

  @override
  final LinkDelegate? linkDelegate = null;

  /// Attach constructor of [MockClient] which contains
  /// simulated responses for incoming URLs.
  @visibleForTesting
  MockUrlLauncherPlatform(MockClient Function() mockClientConstructor)
      : _constructor = mockClientConstructor;

  Future<bool> _interactWithMockClient(
      String url, Future<void> Function(MockClient, Uri) action) async {
    MockClient mc = _constructor();
    bool accessible = false;

    try {
      await action(mc, Uri.parse(url));
      accessible = true;
    } catch (e) {
      // Do nothing
    } finally {
      mc.close();
    }

    return accessible;
  }

  @override
  Future<bool> canLaunch(String url) {
    return _interactWithMockClient(url, (mc, uri) async {
      await mc.head(uri);
    });
  }

  @override
  Future<bool> launch(String url,
      {required bool useSafariVC,
      required bool useWebView,
      required bool enableJavaScript,
      required bool enableDomStorage,
      required bool universalLinksOnly,
      required Map<String, String> headers,
      String? webOnlyWindowName}) {
    return _interactWithMockClient(url, (mc, uri) async {
      await mc.get(uri);
    });
  }

  @override
  Future<void> closeWebView() async {}
}
