import 'package:timezone/standalone.dart' as tz;

class Weather {
  final String location; // City name
  final String region; // State or province
  final String country; // Country name
  final double temperature; // Current temperature in °C
  final String condition; // Weather condition text (e.g., "Sunny")
  final String iconUrl; // URL for the weather condition icon
  final double windSpeed; // Wind speed in km/h
  final int humidity; // Humidity percentage
  final double feelsLike; // Feels like temperature in °C
  final double uvIndex; // UV index
  final String sunrise; // Time of sunrise
  final String sunset; // Time of sunset
  final String moonrise; // Time of moonrise
  final String moonset; // Time of moonset
  final List<Forecast> forecast; // 7-day forecast list
  final AirQuality? airQuality; // Air quality data (optional)
  final String timezone; // Timezone of the location

  Weather({
    required this.location,
    required this.region,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.forecast,
    this.airQuality,
    required this.timezone,
  });

  // Factory method to create Weather object from JSON response.
  factory Weather.fromJson(Map<String, dynamic> json) {
    List<Forecast> forecast = (json['forecast']['forecastday'] as List)
        .map((data) => Forecast.fromJson(data))
        .toList();

    AirQuality? airQuality;
    if (json.containsKey('air_quality')) {
      airQuality = AirQuality.fromJson(json['air_quality']);
    }

    return Weather(
      location: json['location']['name'],
      region: json['location']['region'],
      country: json['location']['country'],
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
      iconUrl: json['current']['condition']['icon'],
      windSpeed: json['current']['wind_kph'],
      humidity: json['current']['humidity'],
      feelsLike: json['current']['feelslike_c'],
      uvIndex: json['current']['uv'],
      sunrise: json['forecast']['forecastday'][0]['astro']['sunrise'],
      sunset: json['forecast']['forecastday'][0]['astro']['sunset'],
      moonrise: json['forecast']['forecastday'][0]['astro']['moonrise'],
      moonset: json['forecast']['forecastday'][0]['astro']['moonset'],
      forecast: forecast,
      airQuality: airQuality,
      timezone: json['location']['tz_id'],
    );
  }

  // Converts a given time string to a timezone-aware DateTime object.
  DateTime getLocalTime(String timeString, DateTime currentDate, String tzId) {
    final location = tz.getLocation(tzId);
    final timeParts = timeString.split(' ');
    final hourMinuteParts = timeParts[0].split(':');
    int hour = int.parse(hourMinuteParts[0]);
    final minute = int.parse(hourMinuteParts[1]);
    final isPM = timeParts[1].toLowerCase() == 'pm';

    // Adjust for PM
    if (isPM && hour != 12) {
      hour += 12;
    }

    // Handle special case of 12 AM
    if (!isPM && hour == 12) {
      hour = 0;
    }

    final dateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      hour,
      minute,
    );

    return tz.TZDateTime.from(dateTime, location);
  }
}

// Represents the forecast for a single day
class Forecast {
  final String date; // Date of the forecast
  final double maxTemp; // Max temperature of the day
  final double minTemp; // Min temperature of the day
  final String condition; // Weather condition for the day
  final String iconUrl; // URL for the condition icon

  Forecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconUrl,
  });

  // Factory method to create Forecast object from JSON response.
  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      condition: json['day']['condition']['text'],
      iconUrl: json['day']['condition']['icon'],
    );
  }
}

// Represents air quality information (optional data)
class AirQuality {
  final double pm25; // PM2.5 level
  final double pm10; // PM10 level
  final double co; // CO level

  AirQuality({
    required this.pm25,
    required this.pm10,
    required this.co,
  });

  // Factory method to create AirQuality object from JSON response.
  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      pm25: json['pm2_5'],
      pm10: json['pm10'],
      co: json['co'],
    );
  }
}
