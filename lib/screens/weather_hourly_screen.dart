import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:weather_today/theme/cloud_bg.dart';
import '../models/hourly_forecast.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../utils/location_utils.dart'; 

class HourlyWeatherScreen extends StatefulWidget {
  final String cityName;
  const HourlyWeatherScreen({super.key, required this.cityName});

  @override
  State<HourlyWeatherScreen> createState() => _HourlyWeatherScreenState();
}

class _HourlyWeatherScreenState extends State<HourlyWeatherScreen> {
  List<HourlyForecast> _hourlyForecast = [];
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
  void didUpdateWidget(covariant HourlyWeatherScreen oldWidget) {
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
      String cityToUse = widget.cityName;
      if (widget.cityName.toLowerCase() == 'auto') {
        cityToUse = await LocationHelper.getCityFromIP() ?? 'Hanoi';
      }
      final dio = Dio();
      final geoRes = await dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {'name': cityToUse, 'count': 1, 'language': 'vi'},
      );
      if (geoRes.data['results'] == null || geoRes.data['results'].isEmpty) {
        throw Exception('Không tìm thấy thành phố');
      }
      final location = geoRes.data['results'][0];
      final lat = location['latitude'];
      final lon = location['longitude'];
      final weatherRes = await dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'hourly': 'temperature_2m,weathercode,windspeed_10m,relative_humidity_2m,surface_pressure,uv_index,precipitation_probability',
          'timezone': 'Asia/Ho_Chi_Minh',
        },
      );
      final hourlyData = weatherRes.data['hourly'];

      final times = (hourlyData['time'] as List<dynamic>?) ?? [];
      final temperatures = (hourlyData['temperature_2m'] as List<dynamic>?) ?? [];
      final weathercodes = (hourlyData['weathercode'] as List<dynamic>?) ?? [];
      final pops = (hourlyData['precipitation_probability'] as List<dynamic>?) ?? [];
      final winds = (hourlyData['windspeed_10m'] as List<dynamic>?) ?? [];

      if (times.isEmpty || temperatures.isEmpty || weathercodes.isEmpty) {
        throw Exception('Dữ liệu thời tiết không hợp lệ');
      }

      final now = DateTime.now();
      int startIndex = times.indexWhere((t) {
        final dt = DateTime.parse(t);
        return dt.isAfter(now) || dt.isAtSameMomentAs(now);
      });
      if (startIndex == -1) startIndex = 0;

      _hourlyForecast = List.generate(24, (i) {
        final idx = startIndex + i;
        if (idx >= times.length) return null;
        final dt = DateTime.parse(times[idx]);
        return HourlyForecast(
          dateTime: dt,
          temperature: (temperatures[idx] as num?)?.toDouble() ?? 0.0,
          iconCode: _getWeatherIcon((weathercodes[idx] as int?) ?? 0),
          condition: _getWeatherDescription((weathercodes[idx] as int?) ?? 0),
          pop: ((pops.isNotEmpty && idx < pops.length ? pops[idx] : 0) as num?)?.toDouble() ?? 0.0,
          windSpeed: ((winds.isNotEmpty && idx < winds.length ? winds[idx] : 0) as num?)?.toDouble() ?? 0.0,
        );
      }).whereType<HourlyForecast>().toList();

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
    final itemWidth = 88.0;
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
    if (_hourlyForecast.isEmpty) return const Center(child: Text('Không có dữ liệu'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Text(
            "Thời tiết mỗi 1 giờ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: RawKeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKey: (event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (!mounted) return;
                  setState(() {
                    if (_selectedIndex < _hourlyForecast.length - 1) {
                      _selectedIndex++;
                      _scrollToIndex(_selectedIndex);
                    }
                  });
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (!mounted) return;
                  setState(() {
                    if (_selectedIndex > 0) {
                      _selectedIndex--;
                      _scrollToIndex(_selectedIndex);
                    }
                  });
                }
              }
            },
            child: Center(
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _hourlyForecast.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _hourlyForecast[index];
                    final hourStr = DateFormat('HH:mm').format(item.dateTime);
                    final isSelected = index == _selectedIndex;
                    return Container(
                      width: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(hourStr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Image.network(
                            'https://openweathermap.org/img/wn/${item.iconCode}@2x.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error_outline, size: 32);
                            },
                          ),
                          Text('${item.temperature.round()}°C',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Text('💧${item.pop.round()}%', style: const TextStyle(fontSize: 11, color: Colors.white)),
                          Text('💨${item.windSpeed.toStringAsFixed(1)}m/s', style: const TextStyle(fontSize: 11, color: Colors.white)),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            Text(item.condition, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
