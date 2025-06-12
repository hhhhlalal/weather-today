import 'package:flutter/material.dart';
import '../screens/search_city_screen.dart';
import '../screens/weather_current_screen.dart';
import '../screens/weather_hourly_screen.dart';
import '../screens/weather_daily_screen.dart';

class MainWeatherScreen extends StatefulWidget {
  const MainWeatherScreen({Key? key}) : super(key: key);

  @override
  State<MainWeatherScreen> createState() => _MainWeatherScreenState();
}

class _MainWeatherScreenState extends State<MainWeatherScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  Future<void> showMenuDialog() async {
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
            child: const Text('Dự báo 5 ngày'),
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
        // Open Search City and after pop, back to current weather page (page 0)
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const SearchCityScreen(),
        ));
        setState(() {
          _currentPage = 0;
          _pageController.jumpToPage(0);
        });
      } else {
        setState(() {
          _currentPage = selected;
          _pageController.jumpToPage(selected);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CurrentWeatherScreen(onShowMenu: showMenuDialog),
          HourlyWeatherScreen(onShowMenu: showMenuDialog),
          DailyWeatherScreen(onShowMenu: showMenuDialog),
        ],
      ),
    );
  }
}
