import 'package:intl/intl.dart';
import 'package:flutter/material.dart';


List<int> secondsToHms(int totalSeconds) {
  int hours = totalSeconds ~/ 3600;
  int minutes = totalSeconds % 3600 ~/ 60;
  int seconds = totalSeconds % 3600 % 60;
  return [hours, minutes, seconds];
}

String formatTime(int milliseconds) {
  return DateFormat.yMMMMd()
      .add_Hms()
      .format(DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal());
}


String formatDateForDisplay(DateTime t) {
  return DateFormat.yMMMEd().format(t);
}

String formatDateForDisplayMillis(int milliseconds) {
  DateTime t = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  return formatDateForDisplay(t);
}


String formatTimeForDisplay(DateTime t, BuildContext context) {
  TimeOfDay beginTime = TimeOfDay(hour: t.hour, minute: t.minute);
  return beginTime.format(context);
}

String formatTimeForDisplayMillis(int milliseconds, BuildContext context) {
  DateTime t = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  return formatTimeForDisplay(t, context);
}

List<int> dayHourMinuteFromMillis(int milliseconds) {
  int minuteInMillis = 60 * 1000;
  int hourInMillis = 60 * minuteInMillis;
  int dayInMillis = 24 * hourInMillis;
  int days = milliseconds ~/ dayInMillis;
  int hours = (milliseconds % dayInMillis) ~/ hourInMillis;
  int minutes = (milliseconds % hourInMillis) ~/ minuteInMillis;
  return [days, hours, minutes];
}

List<int> dayHourMinuteFromSeconds(int seconds) {
  return dayHourMinuteFromMillis(seconds * 1000);
}


String formatMillisToDHM(int millis, BuildContext context) {
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
