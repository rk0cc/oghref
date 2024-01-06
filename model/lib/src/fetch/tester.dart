part of 'fetch.dart';

final class _MetaFetchTester extends MetaFetch {
  _MetaFetchTester()
      : super._(
            additionalSupportedContentType: const {"text/plain"},
            additionalSupportedExtensions: const {"txt"});

  @override
  OgHrefClient _createClient() => MockOgHrefClient();
}
