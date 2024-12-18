import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widget.dart';
import '../utils/colors.dart';
import '../providers/unit_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather.dart';
import 'package:timezone/standalone.dart' as tz;
import 'dart:ui';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();  // Controller for handling location input
  final Color _textColor = Colors.black;  // Default text color
  final Color _iconColor = Colors.black;  // Default icon color
  final Color _cardColor = Colors.white;  // Default card color

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;  // Determine if screen is small

    return Consumer2<WeatherProvider, UnitProvider>(
      builder: (context, weatherProvider, unitProvider, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getBackgroundGradient(context),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Weather App',
                style: GoogleFonts.lato(
                  color: _textColor,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                // Toggle between °C and °F using the unit provider
                GestureDetector(
                  onTap: () {
                    unitProvider.toggleUnit();  // Switch between metric and imperial
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          unitProvider.isMetric ? '°F' : '°C',  // Display the current unit
                          key: ValueKey(unitProvider.isMetric),
                          style: GoogleFonts.lato(
                            color: _iconColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(context, weatherProvider),  // Input for searching by location
                    const SizedBox(height: 30),

                    // Display loading spinner, error message, or the weather widget based on the state
                    if (weatherProvider.loading)
                      const Center(child: CircularProgressIndicator())
                    else if (weatherProvider.errorMessage != null)
                      _buildErrorSection(context, weatherProvider.errorMessage!)
                    else if (weatherProvider.weather != null)
                        Center(
                          child: WeatherWidget(
                            weather: weatherProvider.weather!,
                            textColor: _textColor,
                            iconColor: _iconColor,
                          ),
                        ),

                    const SizedBox(height: 20),

                    // Display the upcoming weather if data is available
                    if (weatherProvider.weather != null)
                      _buildForecastSection(
                        weatherProvider.weather!.forecast,
                        isSmallScreen,
                        unitProvider.isMetric,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Generate background gradient based on the time of day (day/night)
  List<Color> _getBackgroundGradient(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    Weather? weather = weatherProvider.weather;

    if (weather != null) {
      final location = tz.getLocation(weather.timezone);
      final now = tz.TZDateTime.now(location);

      DateTime sunriseTime = _parseTime(weather.sunrise, now);
      DateTime sunsetTime = _parseTime(weather.sunset, now);

      bool isDayTime = now.isAfter(sunriseTime) && now.isBefore(sunsetTime);

      // Daytime background gradient
      if (isDayTime) {
        return [
          Colors.lightBlueAccent,
          Colors.lightBlue,
        ];
      } else {
        // Nighttime background gradient
        return [
          Colors.indigo.shade900,
          Colors.blueGrey.shade800,
        ];
      }
    }

    return [primaryBlue, Colors.blueGrey];  // Default gradient if no weather data
  }

  // Parse time strings (e.g., "6:00 PM") into a DateTime object
  DateTime _parseTime(String timeString, tz.TZDateTime currentDate) {
    final timeParts = timeString.split(' ');
    final hourMinuteParts = timeParts[0].split(':');
    final hour = int.parse(hourMinuteParts[0]);
    final minute = int.parse(hourMinuteParts[1]);

    final isPM = timeParts[1].toLowerCase() == 'pm';
    final parsedHour = isPM ? (hour % 12) + 12 : hour % 12;

    return tz.TZDateTime(
      currentDate.location,
      currentDate.year,
      currentDate.month,
      currentDate.day,
      parsedHour,
      minute,
    );
  }

  // Build the search section for entering a location
  Widget _buildSearchSection(BuildContext context, WeatherProvider weatherProvider) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(),
                ),
                TextField(
                  controller: _controller,
                  style: GoogleFonts.lato(fontSize: 18, color: _textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    hintStyle: GoogleFonts.lato(color: _textColor.withOpacity(0.6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: _iconColor),
                      onPressed: () {
                        String location = _controller.text;
                        if (location.isNotEmpty) {
                          weatherProvider.fetchWeatherByLocation(location);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build the error section when an error message is available
  Widget _buildErrorSection(BuildContext context, String errorMessage) {
    return Column(
      children: [
        Icon(Icons.error, color: Colors.red, size: 48),
        const SizedBox(height: 20),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.redAccent),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Provider.of<WeatherProvider>(context, listen: false)
                .getLocationAndFetchWeather();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  // Build the upcoming forecast section with animated temperature changes
  Widget _buildForecastSection(List<Forecast> forecast, bool isSmallScreen, bool isMetric) {
    final DateFormat dateFormatter = DateFormat('EEEE, MMMM d');

    return Column(
      children: [
        Text('Upcoming Forecast',
            style: GoogleFonts.lato(
                fontSize: 24, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecast.length,
          itemBuilder: (context, index) {
            final day = forecast[index];

            // Convert temperatures based on the current unit
            final maxTemp = isMetric
                ? '${day.maxTemp}°C'
                : '${((day.maxTemp * 9 / 5) + 32).toStringAsFixed(1)}°F';
            final minTemp = isMetric
                ? '${day.minTemp}°C'
                : '${((day.minTemp * 9 / 5) + 32).toStringAsFixed(1)}°F';

            DateTime date = DateTime.parse(day.date);
            String formattedDate = dateFormatter.format(date);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: _cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Display the weather icon
                      Image.network(
                        'https:${day.iconUrl}',
                        height: isSmallScreen ? 50 : 80,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the date
                            Text(
                              formattedDate,
                              style: GoogleFonts.lato(
                                  fontSize: 18, color: _textColor),
                            ),
                            // Display the weather condition
                            Text(
                              day.condition,
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: _textColor.withOpacity(0.7)),
                            ),
                            // Smoothly animate the temperature display when units toggle
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: Text(
                                'High: $maxTemp, Low: $minTemp',
                                key: ValueKey('$maxTemp-$minTemp'),
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: _textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
