import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hourly_forecast.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../utils/openweather_lottie_utils.dart';
import '../utils/openweather_utils.dart';
import 'package:lottie/lottie.dart';

class HourlyWeatherScreen extends StatefulWidget {
  final Future<void> Function()? onShowMenu;
  const HourlyWeatherScreen({super.key, this.onShowMenu});

  @override
  State<HourlyWeatherScreen> createState() => _HourlyWeatherScreenState();
}

class _HourlyWeatherScreenState extends State<HourlyWeatherScreen> {
  List<HourlyForecast> _hourlyForecast = [];
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
    });
    try {
      final coords = await getLatLonFromIP();
      if (coords == null) throw Exception('Không lấy được tọa độ từ IP');
      final list = await fetchHourlyForecastByLatLon(coords['lat']!, coords['lon']!);
      if (list == null) throw Exception('Không lấy được dữ liệu dự báo');

      final tempList = <HourlyForecast>[];
      for (final item in list.take(12)) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final temp = (item['main']['temp'] as num).toDouble();
        final icon = item['weather'][0]['icon'] as String;
        final condition = item['weather'][0]['description'] as String;
        final pop = (item['pop'] ?? 0.0) is num ? (item['pop'] as num).toDouble() * 100 : 0.0;
        final windSpeed = (item['wind']['speed'] as num).toDouble();
        tempList.add(HourlyForecast(
          dateTime: dt,
          temperature: temp,
          iconCode: icon,
          condition: condition,
          pop: pop,
          windSpeed: windSpeed,
        ));
      }

      if (!mounted) return;
      setState(() {
        _hourlyForecast = tempList;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Lỗi: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    const itemWidth = 110.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      math.max(0, offset),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_hourlyForecast.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp && widget.onShowMenu != null) {
      widget.onShowMenu!();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_selectedIndex < _hourlyForecast.length - 1) {
        setState(() {
          _selectedIndex++;
          _scrollToIndex(_selectedIndex);
        });
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_selectedIndex > 0) {
        setState(() {
          _selectedIndex--;
          _scrollToIndex(_selectedIndex);
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi ứng dụng không?'),
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
    if (shouldExit == true) {
      SystemNavigator.pop();
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text(_error!))
            : _hourlyForecast.isEmpty
                ? const Center(child: Text('Không có dữ liệu'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        child: Text(
                          "Dự báo thời tiết (3 tiếng/lần)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 180,
                            child: ListView.separated(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: _hourlyForecast.length,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final item = _hourlyForecast[index];
                                final hourStr = DateFormat('HH:mm dd/MM').format(item.dateTime);
                                final isSelected = index == _selectedIndex;
                                final owmLottie = getOWMLottieWeather(item.iconCode);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 110,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(18),
                                      border: isSelected ? Border.all(color: Colors.blue, width: 2.5) : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(hourStr,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: owmLottie.lottieFile.endsWith('.json')
                                              ? Lottie.asset(
                                                  'assets/lottie/${owmLottie.lottieFile}',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.error_outline, size: 44, color: Colors.white),
                                                )
                                              : const Icon(Icons.cloud, size: 44, color: Colors.grey),
                                        ),
                                        Text('${item.temperature.round()}°C',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        Text('💧${item.pop.round()}%', style: const TextStyle(fontSize: 13, color: Colors.white)),
                                        Text('💨${item.windSpeed.toStringAsFixed(1)}m/s', style: const TextStyle(fontSize: 13, color: Colors.white)),
                                        Text(
                                          owmLottie.viDesc,
                                          style: const TextStyle(fontSize: 13, color: Colors.white),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: content,
      ),
    );
  }
}
