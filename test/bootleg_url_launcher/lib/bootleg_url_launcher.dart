/// Replicated features of [UrlLauncherPlatform] but simulate opening link
/// by making HTTP request.
@visibleForTesting
library bootleg_url_launcher;

import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

export 'src/interface.dart';
