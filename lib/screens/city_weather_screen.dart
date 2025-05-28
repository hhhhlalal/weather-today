import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../models/weather.dart';
import '../models/daily_forecast.dart';
import '../models/hourly_forecast.dart';

class CityWeatherScreen extends StatefulWidget {
  final String cityName;
  const CityWeatherScreen({super.key, required this.cityName});

  @override
  State<CityWeatherScreen> createState() => _CityWeatherScreenState();
}

class _CityWeatherScreenState extends State<CityWeatherScreen> {
  Weather? _weather;
  List<DailyForecast> _dailyForecast = [];
  List<HourlyForecast> _hourlyForecast = [];
  bool _loading = false;
  String? _error;
  final String apiKey = '31599a7d8c68f589489367fb2a3826fb';
  final FocusNode _refreshButtonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchWeather(widget.cityName);
  }

  @override
  void dispose() {
    _refreshButtonFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final dio = Dio();
    try {
      // Weather hiện tại
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi'
        },
      );
      _weather = Weather.fromJson(response.data);

      // Forecast
      final forecastResp = await dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi'
        },
      );
      final list = forecastResp.data['list'] as List<dynamic>;

      // Hourly: 8 mục đầu (mỗi 3h/lần, 24h)
      _hourlyForecast = list.take(8).map((item) => HourlyForecast.fromJson(item)).toList();

      // Daily: group theo ngày, lấy nhiệt độ cao nhất, thấp nhất trong ngày, icon đầu tiên
      Map<String, List<dynamic>> dayMap = {};
      for (var item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dayStr = DateFormat('yyyy-MM-dd').format(dt);
        dayMap.putIfAbsent(dayStr, () => []).add(item);
      }

      _dailyForecast = dayMap.entries.take(6).map((entry) {
        return DailyForecast.fromJson(entry.value[0]);
      }).toList();

      setState(() {});
    } catch (e) {
      setState(() => _error = 'Không thể lấy dữ liệu thời tiết: $e');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        actions: [
          Focus(
            focusNode: _refreshButtonFocus,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _fetchWeather(widget.cityName),
              autofocus: true, // Auto focus on screen load
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : (_weather != null)
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _CurrentWeatherWidget(weather: _weather!),
                          const SizedBox(height: 12),
                          _HourlyForecastWidget(items: _hourlyForecast),
                          const SizedBox(height: 18),
                          _DailyForecastWidget(forecasts: _dailyForecast),
                        ],
                      ),
                    )
                  : const Center(child: Text('Không có dữ liệu')),
    );
  }
}

// --- Widget nhỏ dùng lại như ở current_weather_screen nhưng copy code cho độc lập ---
class _CurrentWeatherWidget extends StatelessWidget {
  final Weather weather;
  const _CurrentWeatherWidget({super.key, required this.weather});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(weather.cityName, style: Theme.of(context).textTheme.headlineMedium),
        Image.network(
          'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 80);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(),
            );
          },
        ),
        Text('${weather.temperature.round()}°C', style: Theme.of(context).textTheme.displayMedium),
        Text(weather.condition, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> items;
  const _HourlyForecastWidget({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          final hourStr = DateFormat('HH:mm').format(item.dateTime);
          return Container(
            width: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hourStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                Image.network(
                  'https://openweathermap.org/img/wn/${item.iconCode}@2x.png',
                  width: 38,
                  height: 38,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error_outline, size: 38);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 38,
                      height: 38,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
                Text('${item.temperature.round()}°C', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('💧${((item.pop) * 100).round()}%', style: const TextStyle(fontSize: 12)),
                Text('💨${item.windSpeed}m/s', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  const _DailyForecastWidget({super.key, required this.forecasts});

  String _getLunarDateStr(DateTime date) {
    // Simple approximation for demo purposes
    final jd = _julianDay(date);
    final lunar = _convertSolar2Lunar(jd);
    return 'Âm: ${lunar[0]}/${lunar[1]}';
  }

  int _julianDay(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;
    
    var a = (14 - month) ~/ 12;
    var y = year + 4800 - a;
    var m = month + 12 * a - 3;
    
    return day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400) - 32045;
  }

  List<int> _convertSolar2Lunar(int jd) {
    // Simplified conversion
    final k = ((jd - 2415021.076998695) / 29.530588853).floor();
    final jd1 = 2415021 + k * 29.530588853;
    
    var monthStart = jd1;
    if (jd >= monthStart) {
      monthStart += 29.530588853;
    }
    
    final day = ((jd - jd1 + 1) % 30).floor() + 1;
    final month = (((jd - 2415021) / 29.530588853) % 12).floor() + 1;
    
    return [day, month];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: forecasts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final day = index == 0
              ? 'Hôm nay'
              : DateFormat.EEEE('vi').format(forecast.date);
          final lunar = _getLunarDateStr(forecast.date);

          return Focus(
            child: Builder(
              builder: (context) {
                final focused = Focus.of(context).hasFocus;
                return ListTile(
                  leading: Image.network(
                    'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                    width: 38,
                    height: 38,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day, 
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: focused ? Colors.blue : null
                        )
                      ),
                      Text(lunar,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${forecast.temperature.round()}°C',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  tileColor: focused ? Colors.blue.withOpacity(0.1) : null,
                  onTap: () {}, // Add empty onTap to make tile focusable
                );
              }
            ),
          );
        },
      ),
    );
  }
}