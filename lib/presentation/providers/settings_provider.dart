import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyBrandName = 'brand_name';
  static const String _defaultBrandName = 'My Store';

  String _brandName = _defaultBrandName;
  bool _isLoaded = false;

  String get brandName => _brandName;
  bool get isLoaded => _isLoaded;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _brandName = prefs.getString(_keyBrandName) ?? _defaultBrandName;
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      _brandName = _defaultBrandName;
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Update brand name and persist to SharedPreferences
  Future<void> setBrandName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    _brandName = trimmed;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBrandName, trimmed);
    } catch (e) {
      debugPrint('Failed to save brand name: $e');
    }
  }

  /// Reset to default brand name
  Future<void> resetBrandName() async {
    await setBrandName(_defaultBrandName);
  }
}
