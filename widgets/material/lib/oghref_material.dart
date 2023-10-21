library oghref_material;

import 'package:oghref_builder/oghref_builder.dart';
import 'package:oghref_media_control/media_control.dart';

export 'package:oghref_builder/oghref_builder.dart';
export 'src/components/carousel.dart';
export 'src/widgets/card.dart';

final class OgHrefMaterial {
  const OgHrefMaterial._();

  static void ensureInitialized() {
    OgHrefMediaControlUnit.ensureInitialized();
    MetaFetch().register(const OpenGraphPropertyParser());
  }
}