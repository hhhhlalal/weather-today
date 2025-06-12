import 'package:flutter/material.dart';

class SelectedCityProvider extends ChangeNotifier {
  String? _cityName;
  double? _lat;
  double? _lon;

  String? get cityName => _cityName;
  double? get lat => _lat;
  double? get lon => _lon;

  bool get hasSelectedCity => _cityName != null && _lat != null && _lon != null;

  void setCity(String cityName, double lat, double lon) {
    _cityName = cityName;
    _lat = lat;
    _lon = lon;
    notifyListeners();
  }

  void clear() {
    _cityName = null;
    _lat = null;
    _lon = null;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': _cityName,
      'lat': _lat,
      'lon': _lon,
    };
  }

  @override
  String toString() {
    return 'SelectedCityProvider{cityName: $_cityName, lat: $_lat, lon: $_lon}';
  }
}