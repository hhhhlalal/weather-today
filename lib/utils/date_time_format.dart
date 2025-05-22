import 'package:intl/intl.dart';

class DateTimeFormat {
  static String getTime(int timeStamp) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return DateFormat('jm').format(time);
  }

  static String getDay(int timeStamp) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return DateFormat('EEE').format(time);
  }

  static String get currentDate => DateFormat("yMMMMd").format(DateTime.now());
}
