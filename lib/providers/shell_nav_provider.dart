import 'package:flutter/material.dart';

/// Tracks which primary tab is active in [MainShell].
class ShellNavProvider with ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int value) {
    if (_index == value) return;
    _index = value;
    notifyListeners();
  }
}
