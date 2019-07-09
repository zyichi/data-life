import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:data_life/models/repeat_types.dart';


class TimeUtil {

  static String formatTime(int milliseconds) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY)
        .add_Hms()
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal());
  }


  static String dateStringFromDateTime(DateTime t) {
    return DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY).format(t);
  }

  static String dateStringFromMillis(int millis) {
    return dateStringFromDateTime(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  static String timeStringFromMillis(int millis, BuildContext context) {
    return timeStringFromDateTime(DateTime.fromMillisecondsSinceEpoch(millis), context);
  }

  static String timeStringFromDateTime(DateTime t, BuildContext context) {
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(t);
    return timeOfDay.format(context);
  }

  static List<int> dayHourMinuteFromMillis(int milliseconds) {
    int days = milliseconds ~/ Duration.millisecondsPerDay;
    int hours = (milliseconds % Duration.millisecondsPerDay) ~/ Duration.millisecondsPerHour;
    int minutes = (milliseconds % Duration.millisecondsPerHour) ~/ Duration.millisecondsPerMinute;
    return [days, hours, minutes];
  }

  static List<int> dayHourMinuteFromSeconds(int seconds) {
    return dayHourMinuteFromMillis(seconds * 1000);
  }

  static String formatMillisToDH(int millis, BuildContext context) {
    var l = dayHourMinuteFromMillis(millis);
    int days = l[0];
    int hours = l[1];
    String dayStr = days == 0 ? '' : '$days days';
    String hourStr = hours == 0 ? '' : '$hours hours';
    String s;
    if (dayStr.isEmpty && hourStr.isEmpty) {
      s = '0 hours';
    } else {
      s = "$dayStr${dayStr.isEmpty ? '' : ' '}$hourStr";
    }
    return s;
  }

  static String formatMillisToDHM(int millis, BuildContext context) {
    var l = dayHourMinuteFromMillis(millis);
    int days = l[0];
    int hours = l[1];
    int minutes = l[2];
    String dayStr = days == 0 ? '' : '$days days';
    String hourStr = hours == 0 ? '' : '$hours hours';
    String minuteStr = minutes == 0 ? '' : '$minutes minutes';
    String s;
    if (dayStr.isEmpty && hourStr.isEmpty && minuteStr.isEmpty) {
      s = '0 minutes';
    } else {
      s = "$dayStr${dayStr.isEmpty ? '' : ' '}$hourStr${hourStr.isEmpty ? '' : ' '}$minuteStr${minuteStr.isEmpty ? '' : ' '}";
    }
    return s;
  }

  static DateTime getDateFromMillis(int millis) {
    var d = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime getDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime dateNow() {
    var d = DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  static WeekdaySeqOfMonth getWeekdaySeqOfMonth(DateTime time) {
    int n = time.day ~/ 7;
    switch (n) {
      case 0:
        return WeekdaySeqOfMonth.first;
      case 1:
        return WeekdaySeqOfMonth.second;
      case 2:
        return WeekdaySeqOfMonth.third;
      case 3:
        var t = DateTime(time.year, (time.month + 1) % 12, 1)
            .subtract(Duration(days: 1));
        if (time.day + 7 > t.day) {
          return WeekdaySeqOfMonth.last;
        }
        return WeekdaySeqOfMonth.fourth;
      default:
        return null;
    }
  }

}
