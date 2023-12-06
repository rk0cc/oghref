import 'package:flutter/cupertino.dart';
import 'package:oghref_cupertino/oghref_cupertino.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'theme_preference.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OgHrefCupertinoBinding.ensureInitialized();

  runApp(const OgHrefCupertinoExampleApp());
}

class OgHrefCupertinoExampleApp extends StatelessWidget {
  const OgHrefCupertinoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ThemePreference(), builder: (context, _) {
      final pref = context.watch<ThemePreference>();

      return CupertinoApp(
        theme: CupertinoThemeData(brightness: pref.darkMode ? Brightness.dark : Brightness.light),
        home: const OgHrefCupertinoExampleHome()
      );
    });
  }

}