import 'package:dio/dio.dart';

Future<String> getLunarDateStrVN(DateTime date) async {
  final url = 'https://open.oapi.vn/date/convert-to-lunar';
  final data = {
    "day": date.day,
    "month": date.month,
    "year": date.year,
  };

  try {
    final dio = Dio();
    final response = await dio.post(url, data: data);

    if (response.statusCode == 200 && response.data["code"] == "success") {
      final lunar = response.data['data'];
      final lunarDay = lunar['day'];
      final lunarMonth = lunar['month'];
      final lunarYear = lunar['year'];
      return 'Âm: ${lunarDay.toString().padLeft(2, '0')}/${lunarMonth.toString().padLeft(2, '0')}';
    } else {
      return 'Không lấy được lịch âm';
    }
  } catch (e) {
    return 'Lỗi lấy lịch âm: $e';
  }
}
