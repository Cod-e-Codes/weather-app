import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitProvider with ChangeNotifier {
  bool _isMetric = true; // Tracks whether the unit is in metric (°C) or imperial (°F)

  bool get isMetric => _isMetric;

  UnitProvider() {
    _loadUnitPreference(); // Loads the stored unit preference on startup
  }

  // Loads the user's unit preference from shared preferences.
  Future<void> _loadUnitPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isMetric = prefs.getBool('isMetric') ?? true; // Default to metric if no preference is found
    notifyListeners();
  }

  // Toggles the unit between metric and imperial and saves it to shared preferences.
  Future<void> toggleUnit() async {
    _isMetric = !_isMetric; // Toggle between °C and °F
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isMetric', _isMetric); // Save the new preference
  }
}
