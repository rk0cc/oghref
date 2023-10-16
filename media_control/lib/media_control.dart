/// A media control unit for display multimedia context
/// in rich information link.
library media_control;

import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/widgets.dart'
    show
        DefaultWidgetsLocalizations,
        LocalizationsDelegate,
        WidgetsFlutterBinding;
import 'package:media_kit/media_kit.dart';

export 'src/aspect_ratio.dart' hide AspectRatioWidgetExtension;
export 'src/player.dart';

///
final class OgHrefMediaControlUnit {
  const OgHrefMediaControlUnit._();

  /// Initialize all necessary libraries uses.
  ///
  /// This must be put after [WidgetsFlutterBinding.ensureInitialized].
  static void ensureInitialized() {
    MediaKit.ensureInitialized();
  }

  /// A [List] containts all default [LocalizationsDelegate] for Flutter
  /// provided app theme (Material and Cupertino).
  ///
  /// Since this library involves Material components, unless there is
  /// [app localization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#adding-your-own-localized-messages)
  /// implemented into your app, it is required to assign these [LocalizationsDelegate]s
  /// when implement into non-Material app:
  ///
  /// ```dart
  /// class NonMaterialApp extends StatelessWidget {
  ///   const NonMaterialApp({super.key});
  ///
  ///   Widget build(BuildContext context) {
  ///     return CupertinoApp(
  ///       localizationDelegates: OgHrefMediaControlUnit.defaultMultiThemeLocalizationDelegates
  ///       // Continue implements below
  ///     );
  ///   }
  /// }
  /// ```
  static const List<LocalizationsDelegate>
      defaultMultiThemeLocalizationDelegates = [
    DefaultMaterialLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate
  ];
}
