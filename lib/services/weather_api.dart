import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherApi {
  // API key and base URL for the Weather API
  static const String apiKey = '0c0a8f464d4e4437bbe191344242509';
  static const String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';

  // Fetches weather data based on latitude and longitude for a specified number of days.
  Future<Weather?> fetchWeather(double latitude, double longitude,
      {int days = 1, bool aqi = false}) async {
    // Construct the URL with the API key, coordinates, and options for forecast days and air quality index (AQI)
    final url = Uri.parse(
        '$baseUrl?key=$apiKey&q=$latitude,$longitude&days=$days&aqi=${aqi ? "yes" : "no"}&alerts=yes');

    final response = await http.get(url);

    // If the request is successful, parse the JSON response into a Weather object
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Weather.fromJson(jsonResponse);
    } else {
      // If the request fails, throw an exception
      throw Exception('Failed to load weather data');
    }
  }

  // Fetches weather data based on a city name for the next 7 days with AQI data.
  Future<Weather?> fetchWeatherByCity(String location) async {
    // Construct the URL with the API key and city name
    final url =
    Uri.parse('$baseUrl?key=$apiKey&q=$location&days=7&aqi=yes&alerts=yes');

    final response = await http.get(url);

    // If the request is successful, parse the JSON response into a Weather object
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Weather.fromJson(jsonResponse);
    } else {
      // If the request fails, throw an exception
      throw Exception('Failed to load weather data');
    }
  }
}
