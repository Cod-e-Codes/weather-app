import 'package:flutter/material.dart';
import '../models/weather.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/unit_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;  // Weather data for display
  final Color textColor;  // Text color for the widget
  final Color iconColor;  // Color for the weather icon

  const WeatherWidget({
    super.key,
    required this.weather,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is small (e.g., mobile)
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    // Access the unit provider to check if the user prefers metric or imperial units
    final unitProvider = Provider.of<UnitProvider>(context);
    final isMetric = unitProvider.isMetric;

    // Convert the temperature based on the preferred unit (°C or °F)
    final temperature = isMetric
        ? '${weather.temperature.toStringAsFixed(1)}°C'
        : '${((weather.temperature * 9 / 5) + 32).toStringAsFixed(1)}°F';

    // Location details (city, state, and country)
    final city = weather.location;
    final state = weather.region;
    final country = weather.country;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display the city and state in large text with auto-sizing to fit the screen
        AutoSizeText(
          '$city, $state',
          style: GoogleFonts.lato(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 1,
          minFontSize: 16,
          overflow: TextOverflow.ellipsis,  // Handle overflow by adding ellipsis
        ),
        // Display the country in smaller text
        Text(
          country,
          style: GoogleFonts.lato(
            fontSize: isSmallScreen ? 16 : 20,
            color: textColor.withOpacity(0.7),
          ),
        ),
        // Display the weather icon with dynamic sizing based on screen size
        Image.network(
          'https:${weather.iconUrl}',
          width: isSmallScreen ? 100 : 150,
          height: isSmallScreen ? 100 : 150,
          fit: BoxFit.contain,
          color: iconColor,
        ),
        // Display the temperature with smooth transition when units change
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            temperature,
            key: ValueKey(temperature),  // Unique key to trigger the animation
            style: GoogleFonts.lato(
              fontSize: isSmallScreen ? 48 : 72,
              fontWeight: FontWeight.w300,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
