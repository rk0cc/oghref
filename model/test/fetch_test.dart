import 'package:get_it/get_it.dart';
import 'package:oghref_model/buffer_parser.dart';
import 'package:oghref_model/src/parser/open_graph.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<MetaFetch>(MetaFetch.forTest()..register(const OpenGraphPropertyParser()));
  });

  test("Test parse under HTTPS", () async {
    final parsed = await GetIt.I<MetaFetch>().fetchFromHttp(Uri.parse(
        'https://raw.githubusercontent.com/rk0cc/oghref/main/model/test_resources/1.html'));

    expect(parsed.title, equals("Sample 1"));
    expect(parsed.images.first.width, equals(400.0));
  });
}
