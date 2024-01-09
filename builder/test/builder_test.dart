import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_builder/testing.dart';

void main() {
  setUpAll(() {
    setupMockInstances();
    MetaFetch.instance = MetaFetch.forTest()
      ..register(const OpenGraphPropertyParser())
      ..primaryPrefix = "og";
  });

  group("Loading builder", () {
    testWidgets("success fetch", (tester) async {
      const ValueKey<String> successKey = ValueKey("success");

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
                  child: OgHrefBuilder.updatable(
                      Uri.parse("https://127.0.0.2/1.html"),
                      onRetrived: (_, __, ___) =>
                          const SizedBox.square(dimension: 30, key: successKey),
                      onFetchFailed: (_, __, ___) =>
                          const SizedBox.square(dimension: 30),
                      onLoading: (_) => const CircularProgressIndicator())))));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(deferPump);

      expect(find.byKey(successKey), findsOneWidget);
    });
    testWidgets("failure fetch (using non-HTTP(S))", (tester) async {
      const ValueKey<String> failureKey = ValueKey("failure");

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
                  child: OgHrefBuilder.updatable(
                      Uri.parse("ftp://127.0.0.2/1.html"),
                      onRetrived: (_, __, ___) =>
                          const SizedBox.square(dimension: 30),
                      onFetchFailed: (_, __, ___) =>
                          const SizedBox.square(dimension: 30, key: failureKey),
                      onLoading: (_) => const CircularProgressIndicator())))));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(deferPump);

      expect(find.byKey(failureKey), findsOneWidget);
    });
  });
}
