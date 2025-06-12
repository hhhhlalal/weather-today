class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double uvIndex;
  final double tempMax;
  final double tempMin;
  final int? cloudiness; 

  Weather({
    required this.tempMax,
    required this.tempMin,
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.uvIndex,
    this.cloudiness,
  });
}
