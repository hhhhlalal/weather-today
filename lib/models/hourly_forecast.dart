class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String iconCode;
  final double pop; // Xác suất mưa
  final double windSpeed;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
    required this.pop,
    required this.windSpeed,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'],
      pop: (json['pop'] ?? 0).toDouble(),
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
    );
  }
}
