import 'package:intl/intl.dart';


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
