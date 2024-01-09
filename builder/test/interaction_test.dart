import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_builder/testing.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

const ValueKey<String> openLinkBtnKey = ValueKey("open_link_button"),
    confirmOpenKey = ValueKey("confirm_open_link");

void main() {
  setUpAll(() {
    setupMockInstances();
    MetaFetch.instance = MetaFetch.forTest()
      ..register(const OpenGraphPropertyParser())
      ..primaryPrefix = "og";
  });

  group("Mock launcher test", () {
    test("determine launchable in mapped URL", () async {
      final Uri validUrl = Uri.parse("https://127.0.0.2/1.html");

      expect(url_launcher.canLaunchUrl(validUrl), completion(isTrue));
      expect(url_launcher.launchUrl(validUrl), completion(isTrue));
    });
    test("determine unlaunchable in mapped URL", () async {
      final Uri invalidUrl = Uri.parse("ftp://127.0.0.2/1.html");

      expect(url_launcher.canLaunchUrl(invalidUrl), completion(isFalse));
      expect(url_launcher.launchUrl(invalidUrl), completion(isFalse));
    });
  });

  group("Builder interaction test", () {
    testWidgets("popup dialog before open link, and no SnackBar appeared",
        (tester) async {
      Future<bool> confirm(BuildContext context, Uri url) async {
        return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                        content: Text("Opening $url"),
                        actions: <TextButton>[
                          TextButton(
                              key: confirmOpenKey,
                              onPressed: () {
                                Navigator.pop<bool>(context, true);
                              },
                              child: const Text("Yes")),
                          TextButton(
                              onPressed: () {
                                Navigator.pop<bool>(context, false);
                              },
                              child: const Text("No"))
                        ])) ??
            false;
      }

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => Center(
                      child: OgHrefBuilder.updatable(
                          Uri.parse("https://127.0.0.2/1.html"),
                          openLinkConfirmation: confirm,
                          onOpenLinkFailed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text("Open link failed"))),
                          onRetrived: (_, __, openLink) => ElevatedButton(
                              key: openLinkBtnKey,
                              onPressed: openLink,
                              child: const Text("Open")),
                          onFetchFailed: (_, __, ___) =>
                              const SizedBox.square(dimension: 30),
                          onLoading: (_) =>
                              const CircularProgressIndicator()))))));

      // Wait the context loaded
      await tester.pump(deferPump);

      final openLink = find.byKey(openLinkBtnKey);
      expect(openLink, findsOneWidget);

      await tester.tap(openLink);
      await tester.pumpAndSettle();

      expect(find.text(r"Opening https://127.0.0.2/1.html"), findsOneWidget);

      final confirmBtn = find.byKey(confirmOpenKey);
      await tester.tap(confirmBtn);
      // Please wait at least more than one seconds for worse case scenrino when making mock request.
      await tester.pumpAndSettle(deferPump);

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("Show SnackBar when launch failed", (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => Center(
                      child: OgHrefBuilder.updatable(
                          Uri.parse("ftp://127.0.0.2/1.html"),
                          onOpenLinkFailed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text("Open link failed"))),
                          onRetrived: (_, __, ___) =>
                              const SizedBox.square(dimension: 30),
                          onFetchFailed: (_, __, openLink) => ElevatedButton(
                              key: openLinkBtnKey,
                              onPressed: openLink,
                              child: const Text("Open")),
                          onLoading: (_) =>
                              const CircularProgressIndicator()))))));

      await tester.pump(deferPump);

      final openLink = find.byKey(openLinkBtnKey);
      expect(openLink, findsOneWidget);

      await tester.tap(openLink);
      await tester.pumpAndSettle(deferPump);

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
