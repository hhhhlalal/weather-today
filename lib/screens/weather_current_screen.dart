import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/current_weather.dart';
import '../utils/date_utils.dart';
import '../utils/openweather_utils.dart';
import '../utils/openweather_lottie_utils.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/selected_city_provider.dart';

class CurrentWeatherScreen extends StatefulWidget {
  final Future<void> Function()? onShowMenu;
  const CurrentWeatherScreen({super.key, this.onShowMenu});

  @override
  State<CurrentWeatherScreen> createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  Weather? _weather;
  bool _loading = false;
  String? _error;
  String? _lunarVN;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _fetchLunar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _fetchLunar() async {
    try {
      final lunarStr = await getLunarDateStrVN(DateTime.now())
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _lunarVN = lunarStr);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _lunarVN = 'Lỗi tải lịch âm');
      }
    }
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final selectedCityProvider = Provider.of<SelectedCityProvider>(context, listen: false);
      Map<String, dynamic>? data;

      if (selectedCityProvider.cityName != null && 
          selectedCityProvider.lat != null && 
          selectedCityProvider.lon != null) {
        data = await fetchCurrentWeatherByLatLon(
          selectedCityProvider.lat!, 
          selectedCityProvider.lon!
        ).timeout(const Duration(seconds: 10));
      } else {
        final coords = await getLatLonFromIP()
            .timeout(const Duration(seconds: 10));
        if (coords == null) {
          throw Exception('Không lấy được tọa độ từ IP');
        }

        data = await fetchCurrentWeatherByLatLon(coords['lat']!, coords['lon']!)
            .timeout(const Duration(seconds: 10));
      }

      if (data == null) {
        throw Exception('Không lấy được dữ liệu thời tiết');
      }

      final weather = data;
      final icon = weather['weather'][0]['icon'] as String;
      final temp = (weather['main']['temp'] as num).toDouble();
      final humidity = (weather['main']['humidity'] as num).toDouble();
      final pressure = (weather['main']['pressure'] as num).toDouble();
      final windSpeed = (weather['wind']['speed'] as num).toDouble();
      final cityName = selectedCityProvider.cityName ?? weather['name'];
      final int? cloudiness = weather['clouds']?['all'] is int ? weather['clouds']['all'] as int : null;

      if (mounted) {
        _weather = Weather(
          cityName: cityName,
          temperature: temp,
          tempMax: temp,
          tempMin: temp,
          condition: weather['weather'][0]['main'],
          iconCode: icon,
          humidity: humidity,
          pressure: pressure,
          windSpeed: windSpeed,
          uvIndex: 0,
          cloudiness: cloudiness,
        );
        setState(() {});
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && widget.onShowMenu != null) {
      widget.onShowMenu!();
      return KeyEventResult.handled;
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

  Widget _buildWeatherIcon(String iconCode) {
    final lottieInfo = getOWMLottieWeather(iconCode);
    return Lottie.asset(
      'assets/lottie/${lottieInfo.lottieFile}',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      repeat: false,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.error_outline, size: 120),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedCityProvider>(
      builder: (context, selectedCityProvider, child) {
        // Tự động fetch lại khi có thành phố mới được chọn
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedCityProvider.cityName != null && _weather?.cityName != selectedCityProvider.cityName) {
            _fetchWeather();
          }
        });

        final content = _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
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
                          onPressed: _fetchWeather,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : _weather == null
                    ? const Center(child: Text('Không có dữ liệu'))
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(fontSize: 17, color: Colors.white),
                            ),
                            Text(
                              _lunarVN ?? 'Đang tải lịch âm...',
                              style: const TextStyle(fontSize: 14, color: Colors.deepOrange),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _weather!.cityName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            _buildWeatherIcon(_weather!.iconCode),
                            Text(
                              '${_weather!.temperature.round()}°C',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Text(
                              getOWMLottieWeather(_weather!.iconCode).viDesc,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Nhiệt độ cảm nhận: ${_weather!.tempMax.round()}°C',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _InfoIcon(
                                  icon: Icons.opacity,
                                  label: 'Độ ẩm',
                                  value: '${_weather!.humidity?.round() ?? "--"}%',
                                ),
                                const SizedBox(width: 20),
                                _InfoIcon(
                                  icon: Icons.compress,
                                  label: 'Áp suất',
                                  value: '${_weather!.pressure.round()} hPa',
                                ),
                                const SizedBox(width: 20),
                                _InfoIcon(
                                  icon: Icons.air,
                                  label: 'Gió',
                                  value: '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                                ),
                                const SizedBox(width: 20),
                                _InfoIcon(
                                  icon: Icons.cloud,
                                  label: 'Mây',
                                  value: '${_weather!.cloudiness?.round() ?? "--"}%',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _handleKeyEvent,
              child: content,
            ),
          ),
        );
      },
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoIcon({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
