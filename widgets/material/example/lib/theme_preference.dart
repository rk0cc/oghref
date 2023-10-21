import 'package:flutter/material.dart';

final class ThemePreference extends ChangeNotifier {
  bool _materialThree;
  bool _darkMode;

  ThemePreference({bool materialThree = false, bool darkMode = false})
      : _materialThree = materialThree,
        _darkMode = darkMode;

  bool get materialThree => _materialThree;

  set materialThree(bool enable) {
    _materialThree = enable;

    notifyListeners();
  }

  bool get darkMode => _darkMode;

  set darkMode(bool enable) {
    _darkMode = enable;

    notifyListeners();
  }
}
