enum HowOften {
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
  oneHour,
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
  userSelectTime,
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
enum DurationUnit {
  Second,
  Minute,
  Hour,
  Day,
  Week,
  Month,
  Year,
}

class DurationValue {
  num value;
  DurationUnit unit;

  DurationValue(value, unit);
}

Map<DurationType, DurationValue> defaultDurationToValueMap = {
  DurationType.oneDay: DurationValue(1, DurationUnit.Day),
  DurationType.oneWeek: DurationValue(1, DurationUnit.Week),
  DurationType.halfMonth: DurationValue(0.5, DurationUnit.Month),
  DurationType.oneMonth: DurationValue(1, DurationUnit.Month),
  DurationType.threeMonth: DurationValue(3, DurationUnit.Month),
  DurationType.halfYear: DurationValue(0.5, DurationUnit.Year),
  DurationType.oneYear: DurationValue(1, DurationUnit.Year),
};
