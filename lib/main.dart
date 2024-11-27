import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/weather_screen.dart';
import 'providers/weather_provider.dart';
import 'providers/unit_provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones(); // Initialize timezone data for proper timezone handling.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Setting up multiple providers for global state management
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()), // Manages weather data
        ChangeNotifierProvider(create: (_) => UnitProvider()), // Manages unit preferences (°C/°F)
      ],
      child: MaterialApp(
        title: 'Flutter Weather App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light, // Default light theme
        ),
        darkTheme: ThemeData(brightness: Brightness.dark), // Dark theme
        themeMode: ThemeMode.system, // Switches between light and dark themes based on system preference
        home: const WeatherScreen(), // Starting point of the app
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
