import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather; // Stores the current weather data
  bool _loading = true; // Tracks if data is loading
  String? _errorMessage; // Stores any error messages

  bool _useMetricUnits = true; // Tracks whether to use metric or imperial units

  Weather? get weather => _weather;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  bool get useMetricUnits => _useMetricUnits;

  Location location = Location(); // Location service for fetching the user's location

  WeatherProvider() {
    _loadUnitPreference(); // Loads the stored unit preference
    getLocationAndFetchWeather(); // Fetch weather based on the user's current location
  }

  // Loads the user's unit preference from shared preferences.
  Future<void> _loadUnitPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _useMetricUnits = prefs.getBool('useMetricUnits') ?? true; // Default to metric if no preference is found
    notifyListeners();
  }

  // Toggles the unit preference and saves it to shared preferences.
  Future<void> toggleUnitPreference() async {
    _useMetricUnits = !_useMetricUnits;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('useMetricUnits', _useMetricUnits);
    notifyListeners();
  }

  // Fetches the user's location and then fetches weather data based on it.
  Future<void> getLocationAndFetchWeather() async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      LocationData locationData = await _determineLocation(); // Gets the user's location
      Weather? weather = await WeatherApi().fetchWeather(
        locationData.latitude!,
        locationData.longitude!,
        days: 7,
        aqi: true,
      );
      _weather = weather;
    } catch (error) {
      _errorMessage = error.toString(); // Stores any errors encountered
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Fetches weather data for a specific city entered by the user.
  Future<void> fetchWeatherByLocation(String location) async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      Weather? weather = await WeatherApi().fetchWeatherByCity(location);
      _weather = weather;
    } catch (error) {
      _errorMessage = error.toString(); // Stores any errors encountered
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Determines the user's current location using location services.
  Future<LocationData> _determineLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled(); // Checks if location services are enabled
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }
    }

    permissionGranted = await location.hasPermission(); // Checks if the app has location permission
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw 'Location permissions are denied.';
      }
    }

    if (permissionGranted == PermissionStatus.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await location.getLocation(); // Fetches the user's current location
  }
}
