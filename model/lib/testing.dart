/// A library uses for testing resources and should not be deployed
/// under production.
@visibleForTesting
library testing;

import 'package:meta/meta.dart';

export 'src/fetch/fetch.dart' show MetaFetchTester, MockOgHrefClientConstructor;
export 'src/client.dart' show MockOgHrefClient;
