library oghref_material;

import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_media_control/media_control.dart';

export 'package:oghref_builder/oghref_builder.dart';
export 'package:oghref_media_control/media_control.dart' show AspectRatioValue;
export 'src/components/carousel.dart';
export 'src/widgets/card.dart';

final class OgHrefMaterialBinding {
  const OgHrefMaterialBinding._();

  static void ensureInitialized() {
    OgHrefMediaControlUnit.ensureInitialized();
    MetaFetch().register(const OpenGraphPropertyParser());
  }
}