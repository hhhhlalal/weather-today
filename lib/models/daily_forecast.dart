class DailyForecast {
  final DateTime date;
  final double temperature;
  final String condition;
  final String iconCode;

  DailyForecast({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}
