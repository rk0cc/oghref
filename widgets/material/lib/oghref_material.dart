/// Material theme library for implementing widgets for rich information link.
library oghref_material;

import 'package:media_kit/media_kit.dart';
import 'package:oghref_builder/oghref_builder.dart';

export 'package:oghref_builder/oghref_builder.dart';
export 'src/components/carousel.dart';
export 'src/widgets/card.dart';
export 'src/widgets/tile.dart';

/// An binding class for initalizing compoents before implementations.
abstract final class OgHrefMaterialBinding {
  const OgHrefMaterialBinding._();

  /// Initalize all necessary setup which will be required to used later.
  static void ensureInitialized() {
    MediaKit.ensureInitialized();
    MetaFetch().register(const OpenGraphPropertyParser());
  }
}
