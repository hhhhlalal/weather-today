import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'theme/dark_theme.dart';
import 'providers/selected_city_provider.dart';
import 'screens/weather_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => SelectedCityProvider(),
      child: const WeatherDemoApp(),
    ),
  );
}

class WeatherDemoApp extends StatelessWidget {
  const WeatherDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: darkWeatherTheme,
      home: const MainWeatherScreen(),
    );
  }
}
