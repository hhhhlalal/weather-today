import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/dark_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(const WeatherDemoApp());
}

class WeatherDemoApp extends StatelessWidget {
  const WeatherDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: darkWeatherTheme,
      home: const HomeScreen(),
    );
  }
}
