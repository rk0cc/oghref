part of 'fetch.dart';

final class _MetaFetchProducer extends MetaFetch {
  _MetaFetchProducer() : super._();

  @override
  OgHrefClient _createClient(bool? redirectOverride) =>
      OgHrefClient(redirectOverride ?? allowRedirect);
}
