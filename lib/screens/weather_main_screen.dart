import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'search_city_screen.dart';
import 'weather_current_screen.dart';
import 'weather_hourly_screen.dart';
import 'weather_daily_screen.dart';

class MainWeatherScreen extends StatefulWidget {
  const MainWeatherScreen({Key? key}) : super(key: key);

  @override
  State<MainWeatherScreen> createState() => _MainWeatherScreenState();
}

class _MainWeatherScreenState extends State<MainWeatherScreen> {
  int _currentPage = 0;
  String _cityName = 'Hanoi';
  final PageController _pageController = PageController(initialPage: 0);

  Future<void> _showMenu() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Chọn trang'),
        children: [
          SimpleDialogOption(
            child: const Text('Thời tiết hiện tại'),
            onPressed: () => Navigator.pop(context, 0),
          ),
          SimpleDialogOption(
            child: const Text('Dự báo theo giờ'),
            onPressed: () => Navigator.pop(context, 1),
          ),
          SimpleDialogOption(
            child: const Text('Dự báo 7 ngày'),
            onPressed: () => Navigator.pop(context, 2),
          ),
          SimpleDialogOption(
            child: const Text('Tìm kiếm thành phố'),
            onPressed: () => Navigator.pop(context, 3),
          ),
        ],
      ),
    );
    if (selected != null) {
      if (!mounted) return;
      if (selected == 3) {
        await _navigateToCitySearch();
      } else {
        setState(() {
          _currentPage = selected;
          _pageController.jumpToPage(_currentPage);
        });
      }
    }
  }

  Future<void> _navigateToCitySearch() async {
    final city = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchCityScreen()),
    );
    if (city != null && city is String && city.isNotEmpty) {
      setState(() {
        _cityName = city;
        _currentPage = 0; // Chuyển về trang Thời tiết hiện tại
        _pageController.jumpToPage(_currentPage);
      });
    }
  }

  DateTime? _lastArrowUpPressed;
  static const _longPressThreshold = Duration(milliseconds: 350);

  void _handleKey(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2 ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        await _navigateToCitySearch();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_lastArrowUpPressed == null) {
          _lastArrowUpPressed = DateTime.now();
        }
      }
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        final now = DateTime.now();
        if (_lastArrowUpPressed != null &&
            now.difference(_lastArrowUpPressed!) > _longPressThreshold) {
          await _navigateToCitySearch();
        } else {
          await _showMenu();
        }
        _lastArrowUpPressed = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKey: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CurrentWeatherScreen(cityName: _cityName),
            HourlyWeatherScreen(cityName: _cityName),
            DailyWeatherScreen(cityName: _cityName, onShowMenu: _showMenu),
          ],
        ),
      ),
    );
  }
}
