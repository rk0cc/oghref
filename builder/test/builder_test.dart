import 'package:bootleg_url_launcher/bootleg_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_model/model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

const ValueKey<String> openLinkBtnKey = ValueKey("open_url");
const ValueKey<String> urlInputKey = ValueKey("url_input");

final class OgHrefBuilderStatus {
  static const String _keyNamePrefix = "oghref_builder";

  static const ValueKey<String> empty = ValueKey("${_keyNamePrefix}_empty");
  static const ValueKey<String> success = ValueKey("${_keyNamePrefix}_success");
  static const ValueKey<String> error = ValueKey("${_keyNamePrefix}_error");
  static const ValueKey<String> launchFailed =
      ValueKey("${_keyNamePrefix}_launch_failed");

  const OgHrefBuilderStatus._();
}

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
  Uri? currentUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(children: [
      TextField(
          key: urlInputKey,
          textInputAction: TextInputAction.go,
          onSubmitted: (newAddr) {
            setState(() {
              currentUrl = Uri.tryParse(newAddr);
            });
          }),
      Expanded(
          child: Center(
              child: currentUrl != null
                  ? OgHrefBuilder.updatable(currentUrl!,
                      onRetrived: (context, metaInfo, openLink) {
                      return GestureDetector(
                          key: OgHrefBuilderStatus.success,
                          onTap: openLink,
                          child: const SizedBox.square(dimension: 30));
                    }, onFetchFailed: (context, error, openLink) {
                      return GestureDetector(
                          key: OgHrefBuilderStatus.error,
                          onTap: openLink,
                          child: const SizedBox.square(dimension: 30));
                    }, onOpenLinkFailed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          key: OgHrefBuilderStatus.launchFailed,
                          content: Text("Launch failed"),
                          duration: Duration(minutes: 1)));
                    }, openLinkConfirmation: (context, _) async {
                      return await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                final nav = Navigator.of(context);
                                return AlertDialog(actions: <ButtonStyleButton>[
                                  ElevatedButton(
                                      key: openLinkBtnKey,
                                      onPressed: () => nav.pop(),
                                      child: const Text("Launch"))
                                ]);
                              }) ??
                          false;
                    })
                  : const SizedBox(key: OgHrefBuilderStatus.empty)))
    ])));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    UrlLauncherPlatform.instance = BootlegUrlLauncher();
    MetaFetch.instance = MetaFetch.forTest()
      ..register(const OpenGraphPropertyParser());
  });

  testWidgets("Simulate builder action with model test resources",
      (tester) async {
    const Map<String, bool> sourceUrls = {
      "https://raw.githubusercontent.com/rk0cc/oghref/main/builder/test_resources/launchable.html":
          true, // Accessible
      "https://127.0.0.2": false // Inaccessible
    };

    await tester.pumpWidget(const MockApp());
    expect(find.byKey(OgHrefBuilderStatus.empty), findsOneWidget);

    for (var MapEntry(key: url, value: accessible) in sourceUrls.entries) {
      await tester.enterText(find.byKey(urlInputKey), url);
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump(const Duration(seconds: 10));

      final successWidget = find.byKey(OgHrefBuilderStatus.success);
      final failureWidget = find.byKey(OgHrefBuilderStatus.error);
      expect(successWidget, accessible ? findsOneWidget : findsNothing);
      expect(failureWidget, accessible ? findsNothing : findsOneWidget);

      await tester.tap(accessible ? successWidget : failureWidget);
      await tester.pump();

      final openLinkBtn = find.byKey(openLinkBtnKey);
      expect(openLinkBtn, findsOneWidget);

      await tester.tap(openLinkBtn);
      await tester.pump(const Duration(seconds: 10, microseconds: 1));

      expect(find.byKey(OgHrefBuilderStatus.launchFailed),
          accessible ? findsNothing : findsOneWidget);
    }
  });
}
