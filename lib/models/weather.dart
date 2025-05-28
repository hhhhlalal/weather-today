class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}
