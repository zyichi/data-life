import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


class TimeUtil {

  static String formatTime(int milliseconds) {
    return DateFormat.yMMMMd()
        .add_Hms()
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal());
  }


  static String dateStringFromDateTime(DateTime t) {
    return DateFormat.yMMMEd().format(t);
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

}
