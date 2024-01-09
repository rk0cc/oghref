// ignore_for_file: invalid_use_of_visible_for_testing_member

/// Offers additional features for [OgHrefBuilder] to run widget test.
///
/// Majority classes, fields and functions are annotated with
/// [visibleForTesting] and should be avoided to use under production
/// or release environment.
library testing;

import 'package:http/testing.dart';
import 'package:meta/meta.dart';
import 'package:oghref_builder/src/builder.dart' show OgHrefBuilder;
import 'package:oghref_model/testing.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'src/mock_url_launcher.dart';

export 'package:http/http.dart' show Request, Response;
export 'package:http/testing.dart' show MockClient;
export 'package:oghref_model/testing.dart';

export 'src/mock_url_launcher.dart';

/// The worse case scenrino [Duration] that the mock client
/// will return response in [Future.delayed].
@visibleForTesting
const Duration deferPump = Duration(seconds: 1, microseconds: 1);

/// Attach [UrlLauncherPlatform.instance] to [MockUrlLauncherPlatform]
/// with completed replication of [MockClient] and parsed as
/// a [Function] for calling [MockClient.new].
///
/// If [mockClientConstructor] is omitted, [MockUrlLauncherPlatform]
/// will attach [MockOgHrefClient.usesSample] as default.
@visibleForTesting
void setupMockInstances([MockClient Function()? mockClientConstructor]) {
  UrlLauncherPlatform.instance = MockUrlLauncherPlatform(
      mockClientConstructor ?? MockOgHrefClient.usesSample);
}
