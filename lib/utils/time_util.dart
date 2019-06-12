import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class TimeUtil {
  static List<int> secondsToHms(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = totalSeconds % 3600 ~/ 60;
    int seconds = totalSeconds % 3600 % 60;
    return [hours, minutes, seconds];
  }

  static String formatTime(int milliseconds) {
    return DateFormat.yMMMMd()
        .add_Hms()
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal());
  }


  static String formatDateTimeForDisplay(DateTime t) {
    return DateFormat.yMMMEd().format(t);
  }

  static String formatDateForDisplayMillis(int milliseconds) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return formatDateTimeForDisplay(t);
  }


  static String formatTimeOfDayForDisplay(DateTime t, BuildContext context) {
    TimeOfDay beginTime = TimeOfDay(hour: t.hour, minute: t.minute);
    return beginTime.format(context);
  }

  static String formatDateTimeForDisplayMillis(int milliseconds, BuildContext context) {
    DateTime t = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return formatTimeOfDayForDisplay(t, context);
  }

  static List<int> dayHourMinuteFromMillis(int milliseconds) {
    int minuteInMillis = 60 * 1000;
    int hourInMillis = 60 * minuteInMillis;
    int dayInMillis = 24 * hourInMillis;
    int days = milliseconds ~/ dayInMillis;
    int hours = (milliseconds % dayInMillis) ~/ hourInMillis;
    int minutes = (milliseconds % hourInMillis) ~/ minuteInMillis;
    return [days, hours, minutes];
  }

  static List<int> dayHourMinuteFromSeconds(int seconds) {
    return dayHourMinuteFromMillis(seconds * 1000);
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


  static DateTime combineTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

}
