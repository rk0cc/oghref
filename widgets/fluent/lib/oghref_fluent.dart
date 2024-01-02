/// Fluent themed widgets for displaying rich information link.
library oghref_fluent;

import 'package:oghref_builder/oghref_builder.dart';
import 'package:media_kit/media_kit.dart';

export 'package:oghref_builder/oghref_builder.dart';
export 'src/components/carousel.dart';
export 'src/typedefs.dart';
export 'src/widgets/card.dart';
export 'src/widgets/tile.dart';

/// An binding class for initalizing compoents before implementations.
abstract final class OgHrefFluentBinding {
  const OgHrefFluentBinding._();

  /// Initalize all necessary setup which will be required to used later.
  static void ensureInitialized() {
    MediaKit.ensureInitialized();
    MetaFetch()
      ..register(const OpenGraphPropertyParser())
      ..primaryPrefix = "og";
  }
}
