import 'weather_data_current.dart';
import 'weather_data_daily.dart';
import 'weather_data_hourly.dart';

class WeatherData {
  final WeatherDataCurrent? current;
  final WeatherDataHourly? hourly;
  final WeatherDataDaily? daily;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.empty() => WeatherData(
        current: null,
        hourly: null,
        daily: null,
      );
}
