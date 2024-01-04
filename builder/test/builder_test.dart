import 'package:bootleg_url_launcher/bootleg_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_model/model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

final class MockApp extends StatelessWidget {
  const MockApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: MockContext());
}

final class MockContext extends StatefulWidget {
  const MockContext({super.key});

  @override
  State<MockContext> createState() => _MockContextState();
}

final class _MockContextState extends State<MockContext> {
  late bool launched;
  late final TextEditingController ctrl;

  @override
  void initState() {
    launched = false;
    super.initState();
    ctrl = TextEditingController();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}


void main() {
  setUpAll(() {
    MetaFetch.instance = MetaFetch.forTest();
    UrlLauncherPlatform.instance = BootlegUrlLauncher();
  });
}
