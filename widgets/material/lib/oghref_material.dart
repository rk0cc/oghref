library oghref_material;

import 'package:media_kit/media_kit.dart';
import 'package:oghref_builder/oghref_builder.dart';

export 'package:oghref_builder/oghref_builder.dart';
export 'src/components/carousel.dart';
export 'src/widgets/card.dart';
export 'src/widgets/tile.dart';

final class OgHrefMaterialBinding {
  const OgHrefMaterialBinding._();

  static void ensureInitialized() {
    MediaKit.ensureInitialized();
    MetaFetch().register(const OpenGraphPropertyParser());
  }
}