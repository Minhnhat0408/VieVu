import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  bool _isSystemOn = true;
  bool get isSystemOn => _isSystemOn;
  void themeSystemOnChanged() {
    _isSystemOn = !_isSystemOn;
    notifyListeners();
  }

  void themeOnChanged() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
