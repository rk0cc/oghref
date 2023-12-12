import 'package:fluent_ui/fluent_ui.dart';
import 'package:oghref_fluent/oghref_fluent.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'theme_preference.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OgHrefFluentBinding.ensureInitialized();

  runApp(const OgHrefFluentExampleApp());
}

class OgHrefFluentExampleApp extends StatelessWidget {
  const OgHrefFluentExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemePreference>(
        create: (_) => ThemePreference(),
        builder: (context, child) {
          final pref = context.watch<ThemePreference>();

          return FluentApp(
              home: const OgHrefFluentExampleHome(),
              themeMode: pref.darkMode ? ThemeMode.dark : ThemeMode.light,
              theme: FluentThemeData()
                  .copyWith(scaffoldBackgroundColor: Colors.blue.lightest),
              darkTheme: FluentThemeData.dark());
        });
  }
}
