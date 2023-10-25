import 'package:get_it/get_it.dart';
import 'package:oghref_model/buffer_parser.dart';
import 'package:oghref_model/src/parser/open_graph.dart';
import 'package:oghref_model/src/parser/twitter_card.dart';
import 'package:test/test.dart';

final Uri resourseUri = Uri.parse(
    "https://raw.githubusercontent.com/rk0cc/oghref/main/model/test_resources");

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<MetaFetch>(MetaFetch.forTest()
      ..register(const OpenGraphPropertyParser())
      ..register(const TwitterCardParser())
      ..primaryPrefix = "og");
  });

  test("Test parse under HTTPS", () async {
    final parsed =
        await GetIt.I<MetaFetch>().fetchFromHttp(resourseUri.resolve("1.html"));

    expect(parsed.title, equals("Sample 1"));
    expect(parsed.images.first.width, equals(400.0));
  });
  test("Ignore subproperties content", () async {
    final parsed =
        await GetIt.I<MetaFetch>().fetchFromHttp(resourseUri.resolve("2.html"));

    expect(parsed.images.first.width, isNull);
    expect(parsed.images.first.height, isNull);
    expect(parsed.images.first.url, isNotNull);
  });

  test("Unaccept JavaScript generated HTML element", () async {
    final parsed =
        await GetIt.I<MetaFetch>().fetchFromHttp(resourseUri.resolve("3.html"));

    expect(parsed.title, isNull);
    expect(parsed.url, isNull);
  });
}
