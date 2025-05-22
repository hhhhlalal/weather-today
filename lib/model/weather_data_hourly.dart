class WeatherDataHourly {
  final List<Hourly> hourly;

  WeatherDataHourly({required this.hourly});

  factory WeatherDataHourly.fromJson(Map<String, dynamic> json) =>
      WeatherDataHourly(
        hourly: (json['hourly'] as List<dynamic>?)
                ?.map((e) => Hourly.fromJson(e))
                .toList() ??
            [],
      );
}

class Hourly {
  final int dt;
  final int temp;
  final List<Weather> weather;

  Hourly({
    required this.dt,
    required this.temp,
    required this.weather,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) => Hourly(
        dt: json['dt'] as int? ?? 0,
        temp: (json['temp'] as num?)?.round() ?? 0,
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
