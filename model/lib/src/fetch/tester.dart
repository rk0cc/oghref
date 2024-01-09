part of 'fetch.dart';

/// A [Function] which returns new instance of [MockOgHrefClient].
typedef MockOgHrefClientConstructor = MockOgHrefClient Function();

/// Extended [MetaFetch] for performing testing purpose which
/// replicates request and response actions in [MockOgHrefClient]
/// since real network communication is forbidden during test
/// (especially running in Flutter environments).
final class MetaFetchTester extends MetaFetch {
  final MockOgHrefClientConstructor _clientConstructor;

  /// Generate new [MetaFetchTester] for running [MetaFetch]
  /// features in simulated environment.
  ///
  /// To apply the features to other `oghref` packages,
  /// please attach it into [MetaFetch.instance].
  MetaFetchTester(MockOgHrefClientConstructor clientConstructor)
      : _clientConstructor = clientConstructor,
        super._(
            additionalSupportedContentType: const {"text/plain"},
            additionalSupportedExtensions: const {"txt"});

  @override
  OgHrefClient _createClient() => _clientConstructor();
}
