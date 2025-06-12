import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_forecast.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../utils/date_utils.dart';
import '../utils/openweather_lottie_utils.dart';
import '../utils/openweather_utils.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class DailyWeatherScreen extends StatefulWidget {
  final Future<void> Function()? onShowMenu;
  const DailyWeatherScreen({super.key, this.onShowMenu});

  @override
  State<DailyWeatherScreen> createState() => _DailyWeatherScreenState();
}

class _DailyWeatherScreenState extends State<DailyWeatherScreen> {
  List<DailyForecast> _dailyForecast = [];
  List<String?> _lunarStrs = [];
  bool _loading = false;
  String? _error;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _selectedIndex = 0;
      _lunarStrs = [];
    });

    try {
      final coords = await getLatLonFromIP()
          .timeout(const Duration(seconds: 10));
      if (coords == null) {
        throw Exception('Không lấy được tọa độ từ IP');
      }

      final list = await fetchHourlyForecastByLatLon(coords['lat']!, coords['lon']!)
          .timeout(const Duration(seconds: 10));
      if (list == null) {
        throw Exception('Không lấy được dữ liệu dự báo');
      }

      // Group theo từng ngày
      final Map<String, List<dynamic>> grouped = {};
      for (final item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dayKey = DateFormat('yyyy-MM-dd').format(dt);
        grouped.putIfAbsent(dayKey, () => []).add(item);
      }

      _dailyForecast = [];
      for (final day in grouped.entries.take(5)) {
        final values = day.value;
        final first = values.first;
        final dt = DateTime.fromMillisecondsSinceEpoch(first['dt'] * 1000);
        final tempMax = values
            .map((e) => (e['main']['temp_max'] as num).toDouble())
            .reduce(math.max);
        final tempMin = values
            .map((e) => (e['main']['temp_min'] as num).toDouble())
            .reduce(math.min);
        final icon = first['weather'][0]['icon'] as String;
        final description = first['weather'][0]['description'] as String;
        final humidity = (first['main']['humidity'] as num?)?.toDouble();

        // Tính trung bình mật độ mây của ngày
        final cloudList = values.map((e) => e['clouds']?['all'] ?? 0).toList();
        final int cloudiness = cloudList.isNotEmpty
            ? (cloudList.reduce((a, b) => a + b) ~/ cloudList.length)
            : 0;

        _dailyForecast.add(DailyForecast(
          date: dt,
          tempMax: tempMax,
          tempMin: tempMin,
          condition: description,
          iconCode: icon,
          humidity: humidity,
          cloudiness: cloudiness,
        ));
      }

      // Khởi tạo mảng lunar strings với đúng kích thước
      if (mounted) {
        _lunarStrs = List<String?>.filled(_dailyForecast.length, null);
        setState(() {});

        // Lấy lịch âm cho từng ngày
        for (int i = 0; i < _dailyForecast.length; i++) {
          _fetchLunarForIndex(i);
        }
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _error = 'Timeout: Không thể kết nối đến server');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Lỗi: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _fetchLunarForIndex(int index) async {
    if (index >= _dailyForecast.length) return;

    try {
      final lunarStr = await getLunarDateStrVN(_dailyForecast[index].date)
          .timeout(const Duration(seconds: 5));
      if (mounted && index < _lunarStrs.length) {
        setState(() => _lunarStrs[index] = lunarStr);
      }
    } catch (e) {
      if (mounted && index < _lunarStrs.length) {
        setState(() => _lunarStrs[index] = 'Lỗi lịch âm');
      }
    }
  }

  void _scrollToIndex(int index) {
    const itemWidth = 180.0;
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp && widget.onShowMenu != null) {
      widget.onShowMenu!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      if (_selectedIndex < _dailyForecast.length - 1) {
        setState(() {
          _selectedIndex++;
          _scrollToIndex(_selectedIndex);
        });
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (_selectedIndex > 0) {
        setState(() {
          _selectedIndex--;
          _scrollToIndex(_selectedIndex);
        });
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn thoát không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Widget _buildWeatherIcon(String iconCode) {
    final owmLottie = getOWMLottieWeather(iconCode);
    return SizedBox(
      width: 44,
      height: 44,
      child: owmLottie.lottieFile.endsWith('.json')
          ? Lottie.asset(
              'assets/lottie/${owmLottie.lottieFile}',
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 44, color: Colors.grey),
            )
          : const Icon(Icons.cloud, size: 44, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_dailyForecast.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu hoặc dữ liệu không hợp lệ'),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text(
              'Dự báo 5 ngày',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _dailyForecast.length,
                itemBuilder: (context, index) {
                  final forecast = _dailyForecast[index];
                  final now = DateTime.now();
                  final isToday = forecast.date.year == now.year &&
                      forecast.date.month == now.month &&
                      forecast.date.day == now.day;
                  final day = isToday
                      ? 'Hôm nay'
                      : DateFormat.EEEE('vi').format(forecast.date);
                  final isSelected = index == _selectedIndex;
                  final owmLottie = getOWMLottieWeather(forecast.iconCode);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyan.shade200.withOpacity(0.85)
                          : Colors.blueGrey.shade800.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(28),
                      border: isSelected
                          ? Border.all(color: Colors.cyanAccent, width: 4)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM').format(forecast.date),
                          style: const TextStyle(fontSize: 13, color: Colors.red),
                        ),
                        Text(
                          (index < _lunarStrs.length && _lunarStrs[index] != null)
                              ? _lunarStrs[index]!
                              : 'Đang tải lịch âm...',
                          style: const TextStyle(fontSize: 13, color: Colors.blue),
                        ),
                        const SizedBox(height: 6),
                        _buildWeatherIcon(forecast.iconCode),
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
                          'Độ ẩm: ${forecast.humidity?.toStringAsFixed(1) ?? '-'}%',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          owmLottie.viDesc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        if (forecast.cloudiness != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud, color: Colors.lightBlueAccent, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  'Mật độ mây: ${forecast.cloudiness}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
