import 'package:dio/dio.dart';

class LocationHelper {
  /// Lấy vị trí thành phố từ địa chỉ IP.
  static Future<String?> getCityFromIP() async {
    try {
      final res = await Dio().get('https://ip-api.com/json');
      if (res.statusCode == 200) {
        return res.data['city'] ?? res.data['regionName'] ?? res.data['country'];
      }
    } catch (e) {
      print('IP Geo Error: $e');
    }
    return null;
  }
}
