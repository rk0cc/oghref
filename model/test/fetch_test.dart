import 'package:oghref_model/buffer_parser.dart';
import 'package:oghref_model/src/fetch/fetch.dart';
import 'package:oghref_model/src/parser/open_graph.dart';
import 'package:oghref_model/src/parser/twitter_card.dart';
import 'package:test/test.dart';

final Uri resourseUri = Uri.parse("https://127.0.0.2/");

Never noResolveInTest() {
  throw UnsupportedError("No resolve process for dummy parser");
}

abstract final class DummyPropertyParser extends MetaPropertyParser {
  const DummyPropertyParser();

  @override
  void resolveMetaTags(
      MetaInfoAssigner assigner, Iterable<PropertyPair> propertyPair) {
    noResolveInTest();
  }
}

final class ValidPropertyParser extends DummyPropertyParser {
  @override
  final String propertyNamePrefix = "valid";

  const ValidPropertyParser();
}

final class InvalidPropertyParser extends DummyPropertyParser {
  @override
  final String propertyNamePrefix = "";

  const InvalidPropertyParser();
}

void main() {
  group("Fetch initialization process:", () {
    setUpAll(() {
      MetaFetch.instance = MetaFetch.forTest();
    });
    test("Only accept parser with named prefix", () {
      expect(() => MetaFetch.instance.register(const ValidPropertyParser()),
          returnsNormally);
      expect(() => MetaFetch.instance.register(const InvalidPropertyParser()),
          throwsA(isA<UnnamedMetaPropertyPrefixError>()));
    });
    group("Interaction with existed parser:", () {
      setUp(() {
        if (!MetaFetch.instance.hasBeenRegistered("valid")) {
          MetaFetch.instance.register(const ValidPropertyParser());
        }
      });
      test("Finding parser", () {
        expect(MetaFetch.instance.hasBeenRegistered("valid"), isTrue);
        expect(MetaFetch.instance.hasBeenRegistered("unexisted"), isFalse);
        expect(() => MetaFetch.instance.hasBeenRegistered(""),
            throwsArgumentError);
      });
      test(
          "Set primary prefix with either null or non-empty string which assigned already",
          () {
        expect(
            () => MetaFetch.instance.primaryPrefix = "valid", returnsNormally);
        expect(() => MetaFetch.instance.primaryPrefix = null, returnsNormally);
        expect(
            () => MetaFetch.instance.primaryPrefix = "", throwsArgumentError);
        expect(() => MetaFetch.instance.primaryPrefix = "foo",
            throwsArgumentError);
      });
      test("Removing parser", () {
        expect(MetaFetch.instance.deregister("valid"), isTrue);
        expect(MetaFetch.instance.deregister("valid"), isFalse);
        expect(() => MetaFetch.instance.deregister(""), throwsArgumentError);
      });
    });
  });
  group("Simulated parser operation:", () {
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
  });
}
