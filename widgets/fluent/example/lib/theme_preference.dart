import 'package:fluent_ui/fluent_ui.dart';

final class ThemePreference extends ChangeNotifier {
  bool _darkMode;

  ThemePreference({bool darkMode = false}) : _darkMode = darkMode;

  bool get darkMode => _darkMode;

  set darkMode(bool enable) {
    _darkMode = enable;

    notifyListeners();
  }
}
