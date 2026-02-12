import 'package:intl/intl.dart';

class DateSeparator {
  static String format(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date); // Monday, Tuesday
    } else {
      return DateFormat('dd MMM yyyy').format(date); // 12 Feb 2026
    }
  }
}
