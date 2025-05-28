import 'package:flutter/material.dart';
import 'city_weather_screen.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  final List<String> _cities = ['Hanoi', 'Ho Chi Minh', 'Paris', 'Tokyo', 'New York'];
  final TextEditingController _controller = TextEditingController();

  void _addCity(String city) {
    if (city.trim().isEmpty) return;
    if (!_cities.contains(city.trim())) {
      setState(() => _cities.add(city.trim()));
    }
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn thành phố')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Thêm thành phố',
                      suffixIcon: Icon(Icons.add),
                    ),
                    onSubmitted: _addCity,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addCity(_controller.text),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(_cities[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CityWeatherScreen(cityName: _cities[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
