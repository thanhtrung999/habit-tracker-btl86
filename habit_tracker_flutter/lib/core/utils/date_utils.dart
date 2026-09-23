import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) {
    return _isoFormat.format(date);
  }

  static DateTime parseDate(String dateStr) {
    try {
      return _isoFormat.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  static bool isToday(String dateStr) {
    return dateStr == formatDate(DateTime.now());
  }

  static String getDayName(DateTime date) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  static String getFriendlyDateString(String dateStr) {
    final date = parseDate(dateStr);
    final now = DateTime.now();
    final todayStr = formatDate(now);
    final yesterdayStr = formatDate(now.subtract(const Duration(days: 1)));
    final tomorrowStr = formatDate(now.add(const Duration(days: 1)));

    if (dateStr == todayStr) {
      return 'Hôm nay, ${date.day} tháng ${date.month}';
    } else if (dateStr == yesterdayStr) {
      return 'Hôm qua, ${date.day} tháng ${date.month}';
    } else if (dateStr == tomorrowStr) {
      return 'Ngày mai, ${date.day} tháng ${date.month}';
    } else {
      const weekdays = [
        'Chủ nhật',
        'Thứ hai',
        'Thứ ba',
        'Thứ tư',
        'Thứ năm',
        'Thứ sáu',
        'Thứ bảy'
      ];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    }
  }

  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
