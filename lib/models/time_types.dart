enum HowOften {
  notRepeat,
  onceMonth,
  twiceMonth,
  onceWeek,
  twiceWeek,
  threeTimesWeek,
  fourTimesWeek,
  fiveTimesWeek,
  sixTimesWeek,
  everyday,
}
enum HowLong {
  fifteenMinutes,
  thirtyMinutes,
  fortyFiveMinutes,
  oneHour,
  oneHourThirtyMinutes,
  twoHours,
  halfDay,
  wholeDay
}
enum BestTime {
  morning,
  afternoon,
  evening,
  anyTime,
}
enum DurationType {
  none,
  customTime,
  oneDay,
  twoDay,
  threeDay,
  oneWeek,
  halfMonth,
  oneMonth,
  threeMonth,
  halfYear,
  oneYear,
  threeYear,
  fiveYear,
  forever,
}


int durationTypeInMillis(DurationType t) {
  switch (t) {
    case DurationType.none:
      return null;
    case DurationType.customTime:
      return null;
    case DurationType.oneDay:
      return Duration(days: 1).inMilliseconds;
    case DurationType.twoDay:
      return Duration(days: 2).inMilliseconds;
    case DurationType.threeDay:
      return Duration(days: 3).inMilliseconds;
    case DurationType.oneWeek:
      return Duration(days: 7).inMilliseconds;
    case DurationType.halfMonth:
      return Duration(days: 15).inMilliseconds;
    case DurationType.oneMonth:
      return Duration(days: 30).inMilliseconds;
    case DurationType.threeMonth:
      return Duration(days: 90).inMilliseconds;
    case DurationType.halfYear:
      return Duration(days: 180).inMilliseconds;
    case DurationType.oneYear:
      return Duration(days: 365).inMilliseconds;
    case DurationType.threeYear:
      return Duration(days: 365 * 3).inMilliseconds;
    case DurationType.fiveYear:
      return Duration(days: 365 * 5).inMilliseconds;
    case DurationType.forever:
      return Duration(days: 365 * 200).inMilliseconds;
  }
  return null;
}
