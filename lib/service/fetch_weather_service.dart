import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../model/weather_data.dart';
import '../model/weather_data_current.dart';
import '../model/weather_data_daily.dart';
import '../model/weather_data_hourly.dart';
import '../api_key.dart';

class FetchWeatherService extends GetxService {
  final Dio _dio = Dio();

  Future<WeatherData?> fetchWeatherData(double lat, double lon) async {
    const String currentApiKey = apiKey;

    final String apiUrl =
        "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$currentApiKey&units=metric&exclude=minutely";

    try {
      final response = await _dio.get(apiUrl);
      log("API Response status: ${response.statusCode}");
      log("API Response data: ${response.data}");

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData == null) {
          log("Empty JSON response");
          return WeatherData.empty();
        }

        final currentData = jsonData['current'] != null
            ? WeatherDataCurrent.fromJson(jsonData)
            : null;

        final hourlyData = jsonData['hourly'] != null
            ? WeatherDataHourly.fromJson(jsonData)
            : null;

        final dailyData = jsonData['daily'] != null
            ? WeatherDataDaily.fromJson(jsonData)
            : null;

        return WeatherData(
          current: currentData,
          hourly: hourlyData,
          daily: dailyData,
        );
      } else {
        log("API Error: ${response.statusCode} - ${response.statusMessage}");
        return WeatherData.empty();
      }
    } catch (e, stackTrace) {
      log("Network error: $e");
      log("Stack trace: $stackTrace");
      return WeatherData.empty();
    }
  }
}
