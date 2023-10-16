library media_control;

import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/widgets.dart'
    show DefaultWidgetsLocalizations, LocalizationsDelegate;
import 'package:media_kit/media_kit.dart';

export 'src/aspect_ratio.dart' hide AspectRatioWidgetExtension;
export 'src/player.dart';

final class OgHrefMediaControlUnit {
  const OgHrefMediaControlUnit._();

  static void ensureInitialized() {
    MediaKit.ensureInitialized();
  }

  static const List<LocalizationsDelegate>
      defaultMultiThemeLocalizationDelegates = [
    DefaultMaterialLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate
  ];
}
