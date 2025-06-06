class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String iconCode;
  final double pop; // Xác suất mưa
  final double windSpeed;
  final String condition;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
    required this.pop,
    required this.windSpeed,
    required this.condition,
  });
}
