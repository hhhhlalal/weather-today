import 'dart:developer';

import '../model/weather_data.dart';
import '../service/fetch_weather_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FetchWeatherService _fetchWeatherService = Get.put(FetchWeatherService());

  final RxBool _isDarkMode = false.obs;
  RxBool get isDarkMode => _isDarkMode;

  final RxBool _isLoading = false.obs;
  RxBool get isLoading => _isLoading;

  final RxString _city = "Loading...".obs;
  RxString get city => _city;

  final Rx<WeatherData> weatherData = WeatherData.empty().obs;

  final Rx<Position?> _currentPosition = Rx<Position?>(null);

  final RxString _locationErrorMessage = ''.obs;
  RxString get locationErrorMessage => _locationErrorMessage;

  @override
  void onInit() {
    super.onInit();
    getLocation();
  }

  Future<void> getLocation() async {
    _isLoading.value = true;
    try {
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        await Geolocator.openLocationSettings();
        isServiceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!isServiceEnabled) {
          _locationErrorMessage.value = "Please enable location services.";
          _isLoading.value = false;
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        _locationErrorMessage.value = "Location permissions are permanently denied.";
        _isLoading.value = false;
        return;
      } else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          _locationErrorMessage.value = "Location permissions are denied.";
          _isLoading.value = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentPosition.value = position;

      _locationErrorMessage.value = '';

      // Fetch weather using dio inside FetchWeatherService (must be dio, check FetchWeatherService code)
      await fetchWeather(position.latitude, position.longitude);
      await getCityFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _locationErrorMessage.value = "Unable to fetch location.";
      log("Error: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    _isLoading.value = true;
    try {
      final result = await _fetchWeatherService.fetchWeatherData(latitude, longitude);

      if (result != null) {
        weatherData.value = result;
        log("Weather data fetched successfully: ${result.current?.toString()}");
      } else {
        weatherData.value = WeatherData.empty();
        log("Failed to fetch weather data");
      }
    } catch (e) {
      log("Error in fetchWeather: $e");
      weatherData.value = WeatherData.empty();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getCityFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      _city.value = placemarks.isNotEmpty ? placemarks[0].locality ?? 'Unknown' : 'Unknown Location';
    } catch (e) {
      _city.value = "Unknown Location";
    }
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
