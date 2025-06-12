import 'package:dio/dio.dart';

const String openWeatherApiKey = '31599a7d8c68f589489367fb2a3826fb'; 

Future<Map<String, double>?> getLatLonFromIP() async {
  try {
    final res = await Dio().get('https://ipinfo.io/json');
    if (res.statusCode == 200 && res.data['loc'] != null) {
      final parts = (res.data['loc'] as String).split(',');
      final lat = double.tryParse(parts[0]);
      final lon = double.tryParse(parts[1]);
      if (lat != null && lon != null) return {'lat': lat, 'lon': lon};
    }
  } catch (e) {
    print('IP Geo Error: $e');
  }
  return null;
}

// Lấy weather hiện tại theo lat/lon
Future<Map<String, dynamic>?> fetchCurrentWeatherByLatLon(double lat, double lon) async {
  final res = await Dio().get(
    'https://api.openweathermap.org/data/2.5/weather',
    queryParameters: {
      'lat': lat,
      'lon': lon,
      'appid': openWeatherApiKey,
      'units': 'metric',
      'lang': 'vi',
    },
  );
  if (res.statusCode == 200) return res.data;
  return null;
}

// Lấy forecast 5 ngày (3h/lần) theo lat/lon
Future<List<dynamic>?> fetchHourlyForecastByLatLon(double lat, double lon) async {
  final res = await Dio().get(
    'https://api.openweathermap.org/data/2.5/forecast',
    queryParameters: {
      'lat': lat,
      'lon': lon,
      'appid': openWeatherApiKey,
      'units': 'metric',
      'lang': 'vi',
    },
  );
  if (res.statusCode == 200 && res.data['list'] != null) return res.data['list'];
  return null;
}

Future<Map<String, double>?> fetchLatLonFromCityName(String cityName) async {
  final res = await Dio().get(
    'https://api.openweathermap.org/geo/1.0/direct',
    queryParameters: {
      'q': cityName,
      'limit': 1,
      'appid': openWeatherApiKey,
    },
  );
  if (res.statusCode == 200 && res.data is List && res.data.length > 0) {
    final data = res.data[0];
    return {
      'lat': (data['lat'] as num).toDouble(),
      'lon': (data['lon'] as num).toDouble(),
    };
  }
  return null;
}