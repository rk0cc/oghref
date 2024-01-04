import 'package:bootleg_url_launcher/bootleg_url_launcher.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_model/model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
        color: const Color(0xF0FEFEFE), home: Center(child: child));
  }
}

void main() {
  setUpAll(() {
    MetaFetch.instance = MetaFetch.forTest();
    UrlLauncherPlatform.instance = BootlegUrlLauncher();
  });
}
