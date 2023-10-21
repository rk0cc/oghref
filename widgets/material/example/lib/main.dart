import 'package:flutter/material.dart';
import 'package:oghref_material/oghref_material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'theme_preference.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OgHrefMaterialBinding.ensureInitialized();
  runApp(const OgHrefMaterialExampleApp());
}

class OgHrefMaterialExampleApp extends StatelessWidget {
  const OgHrefMaterialExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemePreference>(
        create: (context) => ThemePreference(),
        builder: (context, child) {
          final ThemePreference pref = context.watch<ThemePreference>();

          return MaterialApp(
              theme: ThemeData(useMaterial3: pref.materialThree),
              darkTheme: ThemeData.dark(useMaterial3: pref.materialThree),
              themeMode: pref.darkMode ? ThemeMode.dark : ThemeMode.light,
              home: const OgHrefMaterialExampleHome());
        });
  }
}
