import 'package:oghref_model/buffer_parser.dart';
import 'package:oghref_model/src/parser/open_graph.dart';
import 'package:oghref_model/src/parser/twitter_card.dart';
import 'package:test/test.dart';

final Uri resourseUri = Uri.parse("https://127.0.0.2/");

void main() {
  setUpAll(() {
    MetaFetch.instance = MetaFetch.forTest()
      ..register(const OpenGraphPropertyParser())
      ..register(const TwitterCardPropertyParser())
      ..primaryPrefix = "og";
  });

  test("Test parse under HTTPS", () async {
    final parsed =
        await MetaFetch.instance.fetchFromHttp(resourseUri.resolve("1.html"));

    expect(parsed.title, equals("Sample 1"));
    expect(parsed.images.first.width, equals(400.0));
  });
  test("Ignore subproperties content", () async {
    final parsed =
        await MetaFetch.instance.fetchFromHttp(resourseUri.resolve("2.html"));

    expect(parsed.images.first.width, isNull);
    expect(parsed.images.first.height, isNull);
    expect(parsed.images.first.url, isNotNull);
  });

  test("Unaccept JavaScript generated HTML element", () async {
    final parsed =
        await MetaFetch.instance.fetchFromHttp(resourseUri.resolve("3.html"));

    expect(parsed.title, isNull);
    expect(parsed.url, isNull);
  });
}
