import 'package:flutter/material.dart';

class NavBarVisibilityProvider with ChangeNotifier {
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  void setVisible(bool isVisible) {
    if (_isVisible != isVisible) {
      _isVisible = isVisible;
      notifyListeners();
    }
  }
}
