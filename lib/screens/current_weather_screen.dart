import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:flutter/services.dart';

import '../models/weather.dart';
import '../models/daily_forecast.dart';
import '../models/hourly_forecast.dart';

class CurrentWeatherScreen extends StatefulWidget {
  const CurrentWeatherScreen({Key? key}) : super(key: key);

  @override
  State<CurrentWeatherScreen> createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  Weather? _weather;
  List<DailyForecast> _dailyForecast = [];
  List<HourlyForecast> _hourlyForecast = [];
  bool _loading = false;
  String? _error;
  final String apiKey = '31599a7d8c68f589489367fb2a3826fb';
  final String defaultCity = 'Hanoi'; // Thành phố mặc định
  bool _localeInitialized = false;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('vi');
      setState(() {
        _localeInitialized = true;
      });
      _fetchWeather(defaultCity);
    } catch (e) {
      setState(() {
        _error = 'Không thể khởi tạo ngôn ngữ: $e';
      });
    }
  }

  Future<void> _fetchWeather(String city) async {
    if (_loading) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    final dio = Dio();
    try {
      final Future weatherFuture = dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi'
        },
      );

      final Future forecastFuture = dio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi'
        },
      );

      // Gọi API song song
      final results = await Future.wait([weatherFuture, forecastFuture]);
      
      _weather = Weather.fromJson(results[0].data);
      
      final list = results[1].data['list'] as List<dynamic>;

      // Hourly forecast
      _hourlyForecast = list.take(8).map((item) => HourlyForecast.fromJson(item)).toList();

      // Daily forecast
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
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời tiết hiện tại'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchWeather(defaultCity),
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _scrollController.animateTo(
                _scrollController.offset - 100,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _scrollController.animateTo(
                _scrollController.offset + 100,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _weather != null
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            CurrentWeatherWidget(weather: _weather!),
                            const SizedBox(height: 12),
                            HourlyForecastWidget(items: _hourlyForecast),
                            const SizedBox(height: 18),
                            DailyForecastWidget(forecasts: _dailyForecast),
                          ],
                        ),
                      )
                    : const Center(child: Text('Không có dữ liệu')),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// --- Widget nhỏ ---
class CurrentWeatherWidget extends StatelessWidget {
  final Weather weather;
  const CurrentWeatherWidget({super.key, required this.weather});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(weather.cityName, style: Theme.of(context).textTheme.headlineMedium),
        Image.network(
          'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
          width: 80,
          height: 80,
        ),
        Text('${weather.temperature.round()}°C', style: Theme.of(context).textTheme.displayMedium),
        Text(weather.condition, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> items;
  const HourlyForecastWidget({super.key, required this.items});
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

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  const DailyForecastWidget({super.key, required this.forecasts});

  String _getLunarDateStr(DateTime date) {
    // Simple lunar calculation (approximate)
    final lunarCycle = 29.53;
    final diff = date.difference(DateTime(1900, 1, 31));
    final days = diff.inDays % lunarCycle;
    
    // Approximate lunar day
    final lunarDay = (days + 1).round();
    final lunarMonth = ((date.month + 1) % 12) + 1;
    
    return 'Âm: $lunarDay/$lunarMonth';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: forecasts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final day = index == 0
              ? 'Hôm nay'
              : DateFormat.EEEE('vi').format(forecast.date);
          final lunar = _getLunarDateStr(forecast.date);

          return Focus(
            autofocus: index == 0,
            child: Builder(
              builder: (context) {
                final focused = Focus.of(context).hasFocus;
                return ListTile(
                  tileColor: focused ? Colors.blue.withOpacity(0.1) : null,
                  leading: Image.network(
                    'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                    width: 38,
                    height: 38,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day, 
                        style: TextStyle(
                          color: focused ? Colors.blue : null,
                          fontWeight: focused ? FontWeight.bold : null,
                        )
                      ),
                      Text(lunar,
                        style: const TextStyle(fontSize: 12, color: Colors.deepOrange)),
                    ],
                  ),
                  subtitle: Text(forecast.condition),
                  trailing: Text(
                    '${forecast.temperature.round()}°C',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }
}
