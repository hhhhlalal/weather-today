import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:weather_today/theme/cloud_bg.dart';
import '../models/daily_forecast.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../utils/date_utils.dart';

class DailyWeatherScreen extends StatefulWidget {
  final String cityName;
  final Future<void> Function()? onShowMenu;

  const DailyWeatherScreen({super.key, required this.cityName, this.onShowMenu});

  @override
  State<DailyWeatherScreen> createState() => _DailyWeatherScreenState();
}

class _DailyWeatherScreenState extends State<DailyWeatherScreen> {
  List<DailyForecast> _dailyForecast = [];
  bool _loading = false;
  String? _error;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant DailyWeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cityName != oldWidget.cityName) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _selectedIndex = 0;
    });
    try {
      final dio = Dio();
      final geoRes = await dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': widget.cityName, 'count': 1, 'language': 'vi'},
      );
      final results = geoRes.data['results'];
      if (results == null || results is! List || results.isEmpty) {
        throw Exception('Không tìm thấy thành phố');
      }
      final location = results[0];
      final lat = location['latitude'];
      final lon = location['longitude'];
      if (lat == null || lon == null) throw Exception('Không lấy được tọa độ thành phố');

      final weatherRes = await dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'daily': 'weathercode,temperature_2m_max,temperature_2m_min,relative_humidity_2m_max',
          'timezone': 'Asia/Ho_Chi_Minh',
        },
      );

      final dailyData = weatherRes.data['daily'];
      if (dailyData == null) throw Exception('Không lấy được dữ liệu thời tiết!');

      final dates = (dailyData['time'] as List<dynamic>?) ?? [];
      final tempsMax = (dailyData['temperature_2m_max'] as List<dynamic>?) ?? [];
      final tempsMin = (dailyData['temperature_2m_min'] as List<dynamic>?) ?? [];
      final codes = (dailyData['weathercode'] as List<dynamic>?) ?? [];
      final humidities = (dailyData['relative_humidity_2m_max'] as List<dynamic>?) ?? [];

      _dailyForecast = [];
      for (int i = 0; i < dates.length; i++) {
        if (i >= tempsMax.length || i >= tempsMin.length || i >= codes.length) continue;
        final parsedDate = DateTime.tryParse(dates[i].toString());
        if (parsedDate == null) continue;
        _dailyForecast.add(DailyForecast(
          date: parsedDate,
          tempMax: (tempsMax[i] is num) ? (tempsMax[i] as num).toDouble() : 0.0,
          tempMin: (tempsMin[i] is num) ? (tempsMin[i] as num).toDouble() : 0.0,
          condition: _getWeatherDescription((codes[i] is int) ? codes[i] as int : 0),
          iconCode: _getWeatherIcon((codes[i] is int) ? codes[i] as int : 0),
          humidity: (humidities.isNotEmpty && i < humidities.length)
              ? (humidities[i] as num?)?.toDouble()
              : null,
        ));
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Lỗi: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
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

  void _scrollToIndex(int index) {
    final itemWidth = 180.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        math.max(0, offset),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return CloudyBackground(child: Text(_error!));
    if (_dailyForecast.isEmpty) return const Center(child: Text('Không có dữ liệu hoặc dữ liệu không hợp lệ'));

    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (event) async {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_selectedIndex < _dailyForecast.length - 1) {
              setState(() {
                _selectedIndex++;
                _scrollToIndex(_selectedIndex);
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_selectedIndex > 0) {
              setState(() {
                _selectedIndex--;
                _scrollToIndex(_selectedIndex);
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (widget.onShowMenu != null) await widget.onShowMenu!();
          }
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 18),
          Text(
            'Dự báo 7 ngày',
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _dailyForecast.length,
              itemBuilder: (context, index) {
                final forecast = _dailyForecast[index];
                final day = index == 0
                    ? 'Hôm nay'
                    : DateFormat.EEEE('vi').format(forecast.date);
                final isSelected = index == _selectedIndex;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 160),
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyan.shade200.withOpacity(0.85) : Colors.blueGrey.shade800.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(28),
                    border: isSelected ? Border.all(color: Colors.cyanAccent, width: 4) : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.15), blurRadius: 20, spreadRadius: 1)]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ngày dương: ${DateFormat('dd/MM').format(forecast.date)}",
                        style: const TextStyle(fontSize: 13, color: Colors.amberAccent),
                      ),
                      Text(
                        "Ngày âm: ${getLunarDateStr(forecast.date)}",
                        style: const TextStyle(fontSize: 13, color: Colors.orangeAccent),
                      ),
                      const SizedBox(height: 6),
                      Image.network(
                        'https://openweathermap.org/img/wn/${forecast.iconCode}@2x.png',
                        width: 44, height: 44,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 44, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${forecast.tempMax.round()}°C',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${forecast.tempMin.round()}°C',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Độ ẩm: ${forecast.humidity?.round() ?? '-'}%',
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        forecast.condition,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
