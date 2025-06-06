class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String iconCode;
  final double? humidity; 

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.iconCode,
    this.humidity, 
  });
}
