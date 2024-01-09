import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oghref_builder/oghref_builder.dart';

void main() {
  test(
      "Throw assertion error if using real MetaFetch rather than mocked in testing environment",
      () {
    expect(
        () => OgHrefBuilder.updatable(Uri.https("localhost"),
            onRetrived: (_, __, ___) => const SizedBox(),
            onFetchFailed: (_, __, ___) => const SizedBox()),
        throwsAssertionError);
    expect(
        () => OgHrefBuilder.runOnce(Uri.https("localhost"),
            onRetrived: (_, __, ___) => const SizedBox(),
            onFetchFailed: (_, __, ___) => const SizedBox()),
        throwsAssertionError);
  });
}
