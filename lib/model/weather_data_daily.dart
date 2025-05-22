class WeatherDataDaily {
  final List<Daily> daily;

  WeatherDataDaily({required this.daily});

  factory WeatherDataDaily.fromJson(Map<String, dynamic> json) =>
      WeatherDataDaily(
        daily: (json['daily'] as List<dynamic>?)
                ?.map((e) => Daily.fromJson(e))
                .toList() ??
            [],
      );
}

class Daily {
  final int dt;
  final Temp temp;
  final List<Weather> weather;

  Daily({
    required this.dt,
    required this.temp,
    required this.weather,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => Daily(
        dt: json['dt'] as int? ?? 0,
        temp: Temp.fromJson(json['temp']),
        weather: (json['weather'] as List<dynamic>?)
                ?.map((e) => Weather.fromJson(e))
                .toList() ??
            [],
      );
}

class Temp {
  final double day;
  final int min;
  final int max;
  final double night;
  final double eve;
  final double morn;

  Temp({
    required this.day,
    required this.min,
    required this.max,
    required this.night,
    required this.eve,
    required this.morn,
  });

  factory Temp.fromJson(Map<String, dynamic> json) => Temp(
        day: (json['day'] as num?)?.toDouble() ?? 0.0,
        min: (json['min'] as num?)?.round() ?? 0,
        max: (json['max'] as num?)?.round() ?? 0,
        night: (json['night'] as num?)?.toDouble() ?? 0.0,
        eve: (json['eve'] as num?)?.toDouble() ?? 0.0,
        morn: (json['morn'] as num?)?.toDouble() ?? 0.0,
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
