import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:weather_today/theme/cloud_bg.dart';
import '../models/weather.dart';
import '../utils/date_utils.dart';
import '../utils/location_utils.dart'; // <-- Thêm dòng này

class CurrentWeatherScreen extends StatefulWidget {
  final String cityName;
  const CurrentWeatherScreen({super.key, required this.cityName});

  @override
  State<CurrentWeatherScreen> createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  Weather? _weather;
  bool _loading = false;
  String? _error;
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didUpdateWidget(covariant CurrentWeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cityName != oldWidget.cityName) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      String cityToUse = widget.cityName;
      if (widget.cityName.toLowerCase() == 'auto') {
        cityToUse = await LocationHelper.getCityFromIP() ?? 'Hanoi';
      }
      _currentCity = cityToUse;
      final dio = Dio();
      final geoRes = await dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': cityToUse, 'count': 1, 'language': 'vi'},
      );
      final results = geoRes.data['results'];
      if (results == null || results is! List || results.isEmpty) {
        throw Exception('Không tìm thấy thành phố');
      }
      final location = results[0];
      final lat = location['latitude'];
      final lon = location['longitude'];
      if (lat == null || lon == null) {
        throw Exception('Không lấy được tọa độ thành phố');
      }
      final weatherRes = await dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'hourly': 'temperature_2m,weathercode,windspeed_10m,relative_humidity_2m,surface_pressure,uv_index',
          'daily': 'temperature_2m_max,temperature_2m_min',
          'timezone': 'Asia/Ho_Chi_Minh',
        },
      );
      final hourlyData = weatherRes.data['hourly'];
      final dailyData = weatherRes.data['daily'];
      if (hourlyData == null || dailyData == null) {
        throw Exception('Không lấy được dữ liệu thời tiết');
      }
      final now = DateTime.now();
      final currentIndex = now.hour;
      final temperatures = (hourlyData['temperature_2m'] as List<dynamic>?) ?? [];
      final weathercodes = (hourlyData['weathercode'] as List<dynamic>?) ?? [];
      final humidities = (hourlyData['relative_humidity_2m'] as List<dynamic>?) ?? [];
      final pressures = (hourlyData['surface_pressure'] as List<dynamic>?) ?? [];
      final windSpeeds = (hourlyData['windspeed_10m'] as List<dynamic>?) ?? [];
      final uvIndices = (hourlyData['uv_index'] as List<dynamic>?) ?? [];
      final dailyMaxTemps = (dailyData['temperature_2m_max'] as List<dynamic>?) ?? [];
      final dailyMinTemps = (dailyData['temperature_2m_min'] as List<dynamic>?) ?? [];
      if (temperatures.isEmpty || currentIndex >= temperatures.length) {
        throw Exception('Dữ liệu nhiệt độ không hợp lệ');
      }
      _weather = Weather(
        cityName: _currentCity ?? cityToUse,
        temperature: (temperatures[currentIndex] as num?)?.toDouble() ?? 0.0,
        tempMax: (dailyMaxTemps.isNotEmpty ? (dailyMaxTemps[0] as num?)?.toDouble() : null) ?? 0.0,
        tempMin: (dailyMinTemps.isNotEmpty ? (dailyMinTemps[0] as num?)?.toDouble() : null) ?? 0.0,
        condition: _getWeatherDescription((currentIndex < weathercodes.length ? weathercodes[currentIndex] as int? : null) ?? 0),
        iconCode: _getWeatherIcon((currentIndex < weathercodes.length ? weathercodes[currentIndex] as int? : null) ?? 0),
        humidity: (currentIndex < humidities.length ? (humidities[currentIndex] as num?)?.toDouble() : null) ?? 0.0,
        pressure: (currentIndex < pressures.length ? (pressures[currentIndex] as num?)?.toDouble() : null) ?? 0.0,
        windSpeed: (currentIndex < windSpeeds.length ? (windSpeeds[currentIndex] as num?)?.toDouble() : null) ?? 0.0,
        uvIndex: (currentIndex < uvIndices.length ? (uvIndices[currentIndex] as num?)?.toDouble() : null) ?? 0.0,
      );
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Lỗi: ${e.toString()}'; });
    } finally {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  String _getWeatherIcon(int code) {
    switch (code) {
      case 0: return '01d';
      case 1: case 2: case 3: return '02d';
      case 45: case 48: return '50d';
      case 51: case 53: case 55: return '09d';
      case 61: case 63: case 65: return '10d';
      case 71: case 73: case 75: return '13d';
      case 95: return '11d';
      default: return '03d';
    }
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0: return 'Trời quang';
      case 1: case 2: case 3: return 'Trời nhiều mây';
      case 45: case 48: return 'Sương mù';
      case 51: case 53: case 55: return 'Mưa phùn';
      case 61: case 63: case 65: return 'Mưa';
      case 71: case 73: case 75: return 'Tuyết rơi';
      case 95: return 'Giông bão';
      default: return 'Nhiều mây';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return CloudyBackground(child: Text(_error!));
    if (_weather == null) return const Center(child: Text('Không có dữ liệu'));
    final now = DateTime.now();
    final lunarStr = getLunarDateStr(now);
    return CloudyBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${now.day}/${now.month}/${now.year}',
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
          Text(
            lunarStr,
            style: const TextStyle(fontSize: 14, color: Colors.deepOrange),
          ),
          const SizedBox(height: 10),
          Text(_weather!.cityName, style: Theme.of(context).textTheme.headlineMedium),
          Image.network(
            'https://openweathermap.org/img/wn/${_weather!.iconCode}@2x.png',
            width: 120, height: 120,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, size: 120);
            },
          ),
          Text('${_weather!.temperature.round()}°C',
              style: Theme.of(context).textTheme.displayMedium),
          Text(_weather!.condition, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text(
            'Nhiệt độ cao nhất: ${_weather!.tempMax.round()}°C, thấp nhất: ${_weather!.tempMin.round()}°C',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoIcon(icon: Icons.opacity, label: 'Độ ẩm', value: '${_weather!.humidity.round()}%'),
              const SizedBox(width: 20),
              _InfoIcon(icon: Icons.compress, label: 'Áp suất', value: '${_weather!.pressure.round()} hPa'),
              const SizedBox(width: 20),
              _InfoIcon(icon: Icons.air, label: 'Gió', value: '${_weather!.windSpeed.toStringAsFixed(1)} m/s'),
              const SizedBox(width: 20),
              _InfoIcon(icon: Icons.wb_sunny, label: 'UV', value: '${_weather!.uvIndex.toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoIcon({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
      ],
    );
  }
}
