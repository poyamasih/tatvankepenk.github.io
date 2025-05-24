import 'package:flutter/material.dart';

/// A helper class to create TextEditingController that maintains
/// consistent state with the data model.
class PersistentTextController extends TextEditingController {
  final Function(String value) onChanged;
  bool _ignoreChangeNotification = false;

  PersistentTextController({
    required String initialValue,
    required this.onChanged,
  }) : super(text: initialValue);

  @override
  set text(String newText) {
    // Avoid triggering onChanged when the text is programmatically set
    _ignoreChangeNotification = true;
    super.text = newText;
    _ignoreChangeNotification = false;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    // Only call onChanged when the change is from user input
    if (!_ignoreChangeNotification) {
      onChanged(text);
    }
  }
}
