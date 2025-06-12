class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String iconCode;
  final double pop;
  final double windSpeed;
  final String condition;
  final int? cloudiness;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
    required this.pop,
    required this.windSpeed,
    required this.condition,
    this.cloudiness,
  });
}
