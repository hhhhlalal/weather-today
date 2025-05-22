import 'dart:developer';

class WeatherDataCurrent {
  final Current? current;

  WeatherDataCurrent({this.current});

  factory WeatherDataCurrent.fromJson(Map<String, dynamic> json) {
    try {
      final currentJson = json['current'];
      if (currentJson == null) {
        log('current data is null');
        return WeatherDataCurrent(current: null);
      }

      return WeatherDataCurrent(current: Current.fromJson(currentJson));
    } catch (e) {
      log('WeatherDataCurrent parsing error: $e');
      return WeatherDataCurrent(current: null);
    }
  }
}

class Current {
  final int temp;
  final int humidity;
  final int clouds;
  final double uvIndex;
  final double feelsLike;
  final double windSpeed;
  final List<Weather> weather;

  Current({
    required this.temp,
    required this.humidity,
    required this.clouds,
    required this.uvIndex,
    required this.feelsLike,
    required this.windSpeed,
    required this.weather,
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
        temp: (json['temp'] as num?)?.round() ?? 0,
        feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
        humidity: json['humidity'] as int? ?? 0,
        uvIndex: (json['uvi'] as num?)?.toDouble() ?? 0.0,
        clouds: json['clouds'] as int? ?? 0,
        windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
        weather: (json['weather'] as List<dynamic>?)
                ?.map((e) => Weather.fromJson(e))
                .toList() ??
            [],
      );
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: json['id'] as int? ?? 0,
        main: json['main'] as String? ?? '',
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? 'unknown',
      );
}
