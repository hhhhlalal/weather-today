import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'city_list_screen.dart';
import 'current_weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CurrentWeatherScreen(),
    const CityListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                _selectedIndex = 1;
              });
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          }
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: 'Thành phố'),
        ],
      ),
    );
  }
}
